local os = require'os'

M_ = {}

local time_fmt = '%Y-%m-%d %H:%M:%S'
local time_fmt_pattern = 'START_TIME: (%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)'

function M_.start_task()
    local row, _ = unpack(vim.api.nvim_win_get_cursor(0));
    local line = vim.api.nvim_buf_get_lines(0, row - 1, row, true)[1]
    if line:match('^  \\*') == nil or line:match('START_TIME') ~= nil or line:match('DONE_TIME') ~= nil then
        return
    end
    line = line .. '   START_TIME: ' .. os.date(time_fmt)
    vim.api.nvim_buf_set_lines(0, row-1, row, false, { line })
end

function M_.done_task()
    local row, _ = unpack(vim.api.nvim_win_get_cursor(0));
    local line = vim.api.nvim_buf_get_lines(0, row - 1, row, true)[1]
    if line:match('DONE_TIME') ~= nil or line:match('^  \\*') == nil then
        return
    end
    if line:match('START_TIME') == nil then
        line = line .. '   DONE_TIME: ' .. os.date(time_fmt)
        vim.api.nvim_buf_set_lines(0, row-1, row, false, { line })
        return
    end
    local year, month, day, hour, min, sec = line:match(time_fmt_pattern)
    local ts_struct = {year = year, month = month, day = day, hour = hour, min = min, sec = sec}
    local start_ts = os.time(ts_struct)
    local elapsed = os.time() - start_ts
    line = line .. '   DONE_TIME: ' .. os.date(time_fmt) .. '   ELAPSED: '
    if math.floor(elapsed / 3600) ~= 0 then
        line = line .. math.floor(elapsed / 3600) .. 'h'
        elapsed = elapsed % 3600
    end
    if math.floor(elapsed / 60) ~= 0 then
        line = line .. math.floor(elapsed / 60) .. 'm'
        elapsed = elapsed % 60
    end
    line = line .. elapsed .. 's'
    vim.api.nvim_buf_set_lines(0, row-1, row, false, { line })
end

function M_.create_subtask()
    local row, _ = unpack(vim.api.nvim_win_get_cursor(0));
    local line = vim.api.nvim_buf_get_lines(0, row - 1, row, true)[1]
    if line:match('^[%s]*$') ~= nil then
        row = row - 1
    end
    vim.api.nvim_buf_set_lines(0, row, row, true, { '    ** ' })
    vim.api.nvim_win_set_cursor(0, { row + 1, 6 })
    vim.fn.feedkeys('a')
end

function M_.create_task()
    local row, _ = unpack(vim.api.nvim_win_get_cursor(0));
    local line = vim.api.nvim_buf_get_lines(0, row - 1, row, true)[1]
    if line:match('^[%s]*$') ~= nil then
        row = row - 1
    end
    vim.api.nvim_buf_set_lines(0, row, row, true, { '  * ' })
    vim.api.nvim_win_set_cursor(0, { row + 1, 5 })
    vim.fn.feedkeys('a')
end

function M_.create_group()
    local row, _ = unpack(vim.api.nvim_win_get_cursor(0));
    local line = vim.api.nvim_buf_get_lines(0, row - 1, row, true)[1]
    if line:match('^[%s]*$') ~= nil then
        row = row - 1
    end
    if row == 0 then
        vim.api.nvim_buf_set_lines(0, row, row, true, { ':' })
        vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
    else
        vim.api.nvim_buf_set_lines(0, row, row, true, { '', ':' })
        vim.api.nvim_win_set_cursor(0, { row + 2, 0 })
    end
    vim.fn.feedkeys('i')
end

function M_.setup()
    local events = { 'BufRead', 'BufEnter' }
    local opts = {
        silent = true,
        noremap = true,
    }
    for _, event in ipairs(events) do
        vim.api.nvim_create_autocmd(event, {
            group = vim.api.nvim_create_augroup('TodosNvimKeymaps', { clear = false }),
            pattern = '*.todo',
            callback = function()
                vim.bo.filetype = 'todos'
                vim.bo.shiftwidth = 2
                vim.api.nvim_buf_set_keymap(0, 'n', '<leader>tc', [[:lua require'todos'.create_task()<CR>]], opts)
                vim.api.nvim_buf_set_keymap(0, 'n', '<leader>tx', [[:lua require'todos'.create_subtask()<CR>]], opts)
                vim.api.nvim_buf_set_keymap(0, 'n', '<leader>tg', [[:lua require'todos'.create_group()<CR>]], opts)
                vim.api.nvim_buf_set_keymap(0, 'n', '<leader>ts', [[:lua require'todos'.start_task()<CR>]], opts)
                vim.api.nvim_buf_set_keymap(0, 'n', '<leader>td', [[:lua require'todos'.done_task()<CR>]], opts)
            end
        })
    end

    vim.api.nvim_create_autocmd('BufWinLeave', {
        group = vim.api.nvim_create_augroup('TodosNvimFoldsSave', { clear = false }),
        pattern = '*.todo',
        callback = function()
            vim.cmd [[mkview]]
        end
    })

    vim.api.nvim_create_autocmd('BufWinEnter', {
        group = vim.api.nvim_create_augroup('TodosNvimFoldsLoad', { clear = false }),
        pattern = '*.todo',
        callback = function()
            vim.cmd [[loadview]]
        end
    })
end

return M_
