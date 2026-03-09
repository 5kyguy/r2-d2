-- Single-theme setup: list images from backgrounds/ and set background symlink on selection.
Name = "r2-d2-background-selector"
NamePretty = "Background"
Cache = false
HideFromProviderlist = true
SearchName = true

local function ShellEscape(s)
  return "'" .. s:gsub("'", "'\\''") .. "'"
end

function FormatName(filename)
  local name = filename:gsub("^%d+", ""):gsub("^%-", "")
  name = name:gsub("%.[^%.]+$", "")
  name = name:gsub("-", " ")
  name = name:gsub("%S+", function(word)
    return word:sub(1, 1):upper() .. word:sub(2):lower()
  end)
  return name
end

function GetEntries()
  local entries = {}
  local home = os.getenv("HOME")
  local r2d2_base = os.getenv("R2D2_PATH") or (home .. "/.local/share/r2-d2")
  local wallpaper_dir = r2d2_base .. "/backgrounds"

  local handle = io.popen(
    "find " .. ShellEscape(wallpaper_dir)
      .. " -maxdepth 1 -type f \\( -name '*.jpg' -o -name '*.jpeg' -o -name '*.png' -o -name '*.gif' -o -name '*.bmp' -o -name '*.webp' \\) 2>/dev/null | sort"
  )
  if handle then
    for background in handle:lines() do
      local filename = background:match("([^/]+)$")
      if filename then
        table.insert(entries, {
          Text = FormatName(filename),
          Value = background,
          Actions = {
            activate = "r2-d2-theme-bg-set " .. ShellEscape(background),
          },
          Preview = background,
          PreviewType = "file",
        })
      end
    end
    handle:close()
  end

  return entries
end
