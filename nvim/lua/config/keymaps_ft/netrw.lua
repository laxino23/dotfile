return function()
    -- ============================================================
    -- Netrw (File Explorer) | 文件浏览器 | ファイルエクスプローラ
    -- ============================================================
    vim.api.nvim_create_autocmd("FileType", {
        pattern = { "netrw" },
        callback = function()
            -- Hide the status column (line numbers/signs) for a cleaner explorer view
            -- 隐藏 Netrw 中的状态列 (行号/标记)，使界面更整洁
            vim.opt_local.statuscolumn = ""
        end,
        group = "MyIDE",
    })
end
