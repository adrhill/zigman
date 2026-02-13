-- filter.lua — Pandoc Lua filter for Zig language reference HTML
--
-- Two-phase filter:
--   Phase 1: Tag code blocks inside figures with the correct language
--   Phase 2: Default remaining bare code blocks to "zig", strip nav/headers

-- Language mapping from caption text patterns
local function lang_from_caption(caption_text)
  local t = caption_text:lower()
  if t:match("shell") then return "bash" end
  if t:match("^c ") or t == "c" or t:match("%.c$") or t:match("%.h$") then return "c" end
  return "zig"
end

-- Phase 1: Walk figures and tag their code blocks with the right language.
-- This must happen first so phase 2 doesn't blindly default them to "zig".
local phase1 = {
  Figure = function(el)
    -- Extract caption text
    local caption_text = ""
    if el.caption and el.caption.long then
      caption_text = pandoc.utils.stringify(el.caption.long)
    end

    local lang = lang_from_caption(caption_text)

    -- Tag all code blocks inside this figure
    el = el:walk({
      CodeBlock = function(cb)
        cb.classes = { lang }
        return cb
      end
    })

    -- Captioned figures: keep as Figure so Typst show rules can style them
    if caption_text ~= "" then
      return el
    end

    -- No caption: unwrap the figure — return just the inner blocks
    local blocks = {}
    for _, block in ipairs(el.content) do
      table.insert(blocks, block)
    end
    if #blocks > 0 then
      return blocks
    end
    return el.content
  end,
}

-- Phase 2: Everything else — default bare code blocks, strip nav, clean headings
local phase2 = {
  Div = function(el)
    if el.identifier == "navigation" then
      return {}
    end
    if el.identifier == "contents-wrapper" or el.identifier == "contents" then
      return el.content
    end
    return el
  end,

  Header = function(el)
    local new_content = {}
    for _, item in ipairs(el.content) do
      if item.tag == "Link" then
        local is_hdr = false
        if item.classes then
          for _, cls in ipairs(item.classes) do
            if cls == "hdr" then
              is_hdr = true
              break
            end
          end
        end
        if not is_hdr then
          table.insert(new_content, item)
        end
      else
        table.insert(new_content, item)
      end
    end
    el.content = new_content
    return el
  end,

  CodeBlock = function(el)
    if #el.classes == 0 then
      el.classes = { "zig" }
    end
    return el
  end,

  RawBlock = function(el)
    if el.format == "html" then
      if el.text:match("</?figcaption") then return {} end
      if el.text:match("</?figure") then return {} end
      if el.text:match("</?header") then return {} end
    end
    return el
  end,

  Span = function(el)
    if el.classes then
      for _, cls in ipairs(el.classes) do
        if cls:match("^tok%-") then
          return el.content
        end
      end
    end
    return el
  end,

  Link = function(el)
    local anchor = el.target:match("^https?://ziglang%.org/documentation/master/#(.+)")
    if anchor then
      el.target = "#" .. anchor
    end
    return el
  end,
}

return { phase1, phase2 }
