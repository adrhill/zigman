-- filter.lua — Pandoc Lua filter for Zig language reference HTML
--
-- Cleans up Zig-specific HTML quirks during pandoc html→typst conversion:
--   • Strips the #navigation sidebar
--   • Removes .hdr anchor links from headings
--   • Maps figcaption language classes to code block language info
--   • Strips syntax-highlighting <span> classes (let Typst re-highlight)
--   • Cleans up internal cross-reference links

-- Track the language from the most recent figcaption
local next_code_lang = nil

-- Remove the navigation sidebar and other non-content divs
function Div(el)
  if el.identifier == "navigation" then
    return {}
  end
  if el.identifier == "contents-wrapper" then
    -- Unwrap the contents-wrapper, keep its children
    return el.content
  end
  if el.identifier == "contents" then
    return el.content
  end
  return el
end

-- Remove .hdr anchor links inside headings, keep the heading text
function Header(el)
  local new_content = {}
  for _, item in ipairs(el.content) do
    if item.tag == "Link" then
      local dominated_by_hdr = false
      if item.classes then
        for _, cls in ipairs(item.classes) do
          if cls == "hdr" then
            dominated_by_hdr = true
            break
          end
        end
      end
      if not dominated_by_hdr then
        table.insert(new_content, item)
      end
    else
      table.insert(new_content, item)
    end
  end
  el.content = new_content
  return el
end

-- Detect figcaption language classes and store for next code block
function RawBlock(el)
  if el.format == "html" then
    -- Check for figcaption with language class
    local zig = el.text:match('class="zig%-cap"')
    local c_lang = el.text:match('class="c%-cap"')
    local shell = el.text:match('class="shell%-cap"')

    if zig then
      next_code_lang = "zig"
      return {}
    elseif c_lang then
      next_code_lang = "c"
      return {}
    elseif shell then
      next_code_lang = "shell"
      return {}
    end

    -- Strip remaining figcaption tags
    if el.text:match("</?figcaption") then
      return {}
    end

    -- Strip figure tags (pandoc sometimes leaves them as raw HTML)
    if el.text:match("</?figure") then
      return {}
    end

    -- Strip the header element
    if el.text:match("</?header") then
      return {}
    end
  end
  return el
end

-- Apply stored language to code blocks and strip highlighting spans
function CodeBlock(el)
  if next_code_lang then
    el.classes = { next_code_lang }
    next_code_lang = nil
  end
  return el
end

-- Strip span-based syntax highlighting classes, keep text content
function Span(el)
  local is_tok = false
  if el.classes then
    for _, cls in ipairs(el.classes) do
      if cls:match("^tok%-") then
        is_tok = true
        break
      end
    end
  end
  if is_tok then
    return el.content
  end
  return el
end

-- Clean up internal links: convert absolute ziglang.org doc links to local anchors
function Link(el)
  local target = el.target
  -- Convert absolute doc links to relative anchors
  local anchor = target:match("^https?://ziglang%.org/documentation/master/#(.+)")
  if anchor then
    el.target = "#" .. anchor
  end
  return el
end

-- Remove the HTML <aside> wrapper but keep content as a block quote
function BlockQuote(el)
  return el
end
