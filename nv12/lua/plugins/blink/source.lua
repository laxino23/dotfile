local source = {
  default = { "supermaven", "lsp", "path", "snippets", "buffer" },

  providers = {
    supermaven = {
      name = "supermaven",
      module = "blink.compat.source",
      score_offset = 100,
      async = true,
    },

    lsp = {
      fallbacks = { "buffer" },
    },

    path = {
      score_offset = 3,
      opts = {
        trailing_slash = false,
        label_trailing_slash = true,
        get_cwd = function(context)
          return vim.fn.expand(("#%d:p:h"):format(context.bufnr or 0))
        end,
        show_hidden_files_by_default = true,
      },
    },

    buffer = {
      min_keyword_length = 2,
    },

    snippets = {
      score_offset = 1000,
      should_show_items = function(ctx)
        return ctx.trigger.initial_kind ~= "trigger_character"
      end,
      opts = {
        friendly_snippets = true,
        search_paths = { vim.fn.stdpath("config") .. "/snippets" },
      },
    },

    cmdline = {
      name = "cmdline",
      module = "blink.cmp.sources.cmdline",
    },
    thesaurus = {
      name = "blink-cmp-words",
      module = "blink-cmp-words.thesaurus",
      opts = {
        score_offset = 0,
        definition_pointers = { "!", "&", "^" },
        similarity_pointers = { "&", "^" },
        similarity_depth = 2,
      },
    },
    dictionary = {
      name = "blink-cmp-words",
      module = "blink-cmp-words.dictionary",
      opts = {
        dictionary_search_threshold = 3,
        score_offset = 0,
        definition_pointers = { "!", "&", "^" },
      },
    },
  },

  per_filetype = {
    text = { "supermaven", "dictionary", "buffer", "path" },
    markdown = { "supermaven", "thesaurus", "dictionary", "snippets", "buffer", "path" },
    typst = { "supermaven", "lsp", "snippets", "dictionary", "path" },
    tex = { "supermaven", "lsp", "dictionary", "thesaurus", "path", "snippets" },
  },
}

return { source = source }
