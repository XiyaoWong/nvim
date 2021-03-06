local api = vim.api
local fn = vim.fn

------------ notification -------------

local function get_last_notification()
  for _, win in ipairs(api.nvim_list_wins()) do
    local buf = api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == 'vim-notify' and api.nvim_win_is_valid(win) then
      return api.nvim_win_get_config(win)
    end
  end
end

local notification_hl = setmetatable({
  [2] = { 'FloatBorder:NvimNotificationError', 'NormalFloat:NvimNotificationError' },
  [1] = { 'FloatBorder:NvimNotificationInfo', 'NormalFloat:NvimNotificationInfo' },
}, {
  __index = function(t, k)
    return k > 1 and t[2] or t[1]
  end,
})

---Utility function to create a notification message
---@param lines string[] | string
---@param opts table
function wxy.notify(lines, opts)
  lines = type(lines) == 'string' and { lines } or lines
  lines = vim.tbl_flatten(vim.tbl_map(function(line)
    return vim.split(line, '\n')
  end, lines))
  opts = opts or {}
  local highlights = { 'NormalFloat:Normal' }
  local level = opts.log_level or 1
  local timeout = opts.timeout or 5000

  local width
  for i, line in ipairs(lines) do
    line = '  ' .. line .. '  '
    lines[i] = line
    local length = #line
    if not width or width < length then
      width = length
    end
  end
  local buf = api.nvim_create_buf(false, true)
  api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  local height = #lines
  local prev = get_last_notification()
  local row = prev and prev.row[false] - prev.height - 2 or vim.o.lines - vim.o.cmdheight - 3
  local win = api.nvim_open_win(buf, false, {
    relative = 'editor',
    width = width + 2,
    height = height,
    col = vim.o.columns - 2,
    row = row,
    anchor = 'SE',
    style = 'minimal',
    focusable = false,
    border = 'double',
  })

  local level_hl = notification_hl[level]

  vim.list_extend(highlights, level_hl)
  vim.wo[win].winhighlight = table.concat(highlights, ',')

  vim.bo[buf].filetype = 'vim-notify'
  vim.wo[win].wrap = true
  if timeout then
    vim.defer_fn(function()
      if api.nvim_win_is_valid(win) then
        api.nvim_win_close(win, true)
      end
    end, timeout)
  end
end

if vim.notify then
  ---Override of vim.notify to open floating window
  --@param message of the notification to show to the user
  --@param log_level Optional log level
  --@param opts Dictionary with optional options (timeout, etc)
  vim.notify = function(message, log_level, _)
    assert(message, 'The message key of vim.notify should be a string')
    wxy.notify(message, { timeout = 5000, log_level = log_level })
  end
end

------------------------------------------

---Check if a cmd is executable
---@param e string
---@return boolean
function wxy.executable(e)
  return fn.executable(e) > 0
end

---Check if directory exists using vim's isdirectory function
---@param path string
---@return boolean
function wxy.is_dir(path)
  return fn.isdirectory(path) > 0
end

---Determine if a value of any type is empty
---@param item any
---@return boolean
function wxy.empty(item)
  if not item then
    return true
  end
  local item_type = type(item)
  if item_type == 'string' then
    return item == ''
  elseif item_type == 'table' then
    return vim.tbl_isempty(item)
  end
end
