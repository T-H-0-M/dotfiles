local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  s("mcol2", {
    t({ "--- start-multi-column: ID_" }), i(1, "001"),
    t({ "", "```column-settings", "Number of Columns: 2", "Largest Column: " }), i(2, "standard"),
    t({ "", "```", "", "" }), i(3, "Left column content."),
    t({ "", "", "--- column-end ---", "", "" }), i(4, "Right column content."),
    t({ "", "", "--- end-multi-column" }),
    i(0),
  }),

  s("mcol3", {
    t({ "--- start-multi-column: ID_" }), i(1, "001"),
    t({ "", "```column-settings", "Number of Columns: 3", "Largest Column: " }), i(2, "standard"),
    t({ "", "```", "", "" }), i(3, "Left column."),
    t({ "", "", "--- column-end ---", "", "" }), i(4, "Middle column."),
    t({ "", "", "--- column-end ---", "", "" }), i(5, "Right column."),
    t({ "", "", "--- end-multi-column" }),
    i(0),
  }),
}
