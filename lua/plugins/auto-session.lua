return {
    'rmagatti/auto-session',
    config = function()
        require("auto-session").setup {
            log_level = "error",
            auto_session_enable_last_session = true,
            auto_session_auto_restore = true,
            auto_session_dir = vim.fn.stdpath('config') .. '/sessions/'
        }
    end
}
