return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "prettierd",
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        ["_"] = { "prettierd" },
      },
      formatters = {
        prettierd = {
          prepend_args = {
            "--semi",
            "--trailing-comma=es5",
            "--single-quote",
            "--print-width=80",
            "--tab-width=2",
            "--arrow-parens=always",
          },
        },
      },
    },
  },
}
