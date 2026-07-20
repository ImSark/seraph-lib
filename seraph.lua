-- ═══════════════════════════════════════════════════════════════
-- SKIDAPH UI LIBRARY
-- ═══════════════════════════════════════════════════════════════

if getgenv().loaded then
    pcall(function()
        getgenv().library:unload_menu()
        for i, v in next, getgenv().connections do v:Disconnect() end
    end)
end
getgenv().loaded = true

-- ── Fallbacks ──
local cloneref = cloneref or function(obj) return obj end
local gethui = gethui or function() return game:GetService("CoreGui") end
local unload_full = unload_full or function() end

local seraphAcc = seraphAcc or {
    username = "user",
    role = "whitelisted",
    theme = nil,
    hexColor = "#9b59b6",
    userid = 1,
}

-- ── Services ──
local uis = game:GetService("UserInputService")
local players = game:GetService("Players")
local ws = game:GetService("Workspace")
local http_service = game:GetService("HttpService")
local gui_service = game:GetService("GuiService")
local lighting = game:GetService("Lighting")
local run = game:GetService("RunService")
local coregui = cloneref(game:GetService("CoreGui"))
local tween_service = game:GetService("TweenService")

-- ── Shortcuts ──
local vec2 = Vector2.new
local vec3 = Vector3.new
local dim2 = UDim2.new
local dim = UDim.new
local dim_offset = UDim2.fromOffset
local rgb = Color3.fromRGB
local hex = Color3.fromHex
local rgbseq = ColorSequence.new
local rgbkey = ColorSequenceKeypoint.new
local numseq = NumberSequence.new
local numkey = NumberSequenceKeypoint.new
local camera = ws.CurrentCamera
local lp = players.LocalPlayer
if not lp then
    repeat run.RenderStepped:Wait() lp = players.LocalPlayer until lp
end
local mouse = lp:GetMouse()
local gui_offset = gui_service:GetGuiInset().Y
local floor = math.floor
local clamp = math.clamp
local random = math.random
local insert = table.insert
local find = table.find
local remove = table.remove
local concat = table.concat

local guiDebounce = false
local keybinds = {}

-- ═══════════════════════════════════════════════════════════════
-- LOADING SCREEN
-- ═══════════════════════════════════════════════════════════════

local isDone

local function get(url)
    local ok, res = pcall(function() return game:HttpGet(url) end)
    if ok and res then return res end
    local ok2, res2 = pcall(function()
        return request({ Url = url, Method = "GET", Headers = { ["User-Agent"] = "Mozilla/5.0" } }).Body
    end)
    return ok2 and res2 or ""
end

makefolder("seraph")
makefolder("seraph/cache")
makefolder("seraph/configs")
makefolder("seraph/sounds")
makefolder("seraph/imgs")

task.spawn(function()
    local load = Instance.new("ScreenGui")
    load.Name = "load"
    load.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    load.Parent = coregui
    load.ResetOnSpawn = false

    local frame = Instance.new("Frame")
    frame.Name = "frame"
    frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    frame.Size = UDim2.new(0, 0, 0, 25)
    frame.BackgroundColor3 = Color3.new(0, 0, 0)
    frame.BorderSizePixel = 0
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.AutomaticSize = Enum.AutomaticSize.X
    frame.Parent = load
    Instance.new("UICorner", frame)

    local icon = Instance.new("ImageLabel")
    icon.Name = "icon"
    icon.Size = UDim2.new(0, 25, 0, 25)
    icon.BackgroundTransparency = 1
    icon.BorderSizePixel = 0
    icon.Transparency = 1
    icon.Image = "rbxassetid://101942723117519"
    icon.Parent = frame

    for _, cfg in ipairs({
        { thickness = 2, transparency = 0 }, { thickness = 2.5, transparency = 0.25 },
        { thickness = 3, transparency = 0.5 }, { thickness = 4, transparency = 0.75 },
        { thickness = 8, transparency = 0.99 }, { thickness = 4.5, transparency = 0.8 },
        { thickness = 5, transparency = 0.85 }, { thickness = 5.5, transparency = 0.9 },
    }) do
        local s = Instance.new("UIStroke")
        s.Thickness = cfg.thickness
        s.Transparency = cfg.transparency
        s.Parent = frame
    end

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = frame

    local fps = Instance.new("TextLabel")
    fps.Name = "fps"
    fps.Size = UDim2.new(0, 0, 0, 25)
    fps.BackgroundTransparency = 1
    fps.BorderSizePixel = 0
    fps.AutomaticSize = Enum.AutomaticSize.X
    fps.LayoutOrder = 7
    fps.Text = "Preparing setup.."
    fps.TextColor3 = Color3.new(0.957, 0.957, 0.957)
    fps.TextSize = 16
    fps.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    fps.Parent = frame

    local pad = Instance.new("UIPadding")
    pad.PaddingRight = UDim.new(0, 5)
    pad.Parent = frame

    frame.Visible = false
    task.wait(0.5)
    frame.Visible = true

    fps.TextTransparency = 1
    icon.ImageTransparency = 1
    frame.BackgroundTransparency = 1
    tween_service:Create(fps, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { TextTransparency = 0 }):Play()
    tween_service:Create(icon, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { ImageTransparency = 0 }):Play()
    tween_service:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { BackgroundTransparency = 0 }):Play()
    tween_service:Create(icon, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { ImageColor3 = Color3.new() }):Play()

    for _, stroke in frame:GetChildren() do
        if stroke:IsA("UIStroke") then
            local trans = stroke.Transparency
            stroke.Transparency = 1
            tween_service:Create(stroke, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Transparency = trans }):Play()
        end
    end

    task.wait(0.25)

    if not isfile("seraph/cache/seraphdata.gif") then
        makefolder("seraph/gifs")
        tween_service:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Position = UDim2.new(0.5, 0, 0.1, 0) }):Play()
        local batchSize = 10
        for i = 1, 150, batchSize do
            for j = i, math.min(i + batchSize - 1, 150) do
                local frameName = string.format("frame_%03d_delay-0.02s.png", j - 1)
                task.spawn(function()
                    local data = get("https://raw.githubusercontent.com/ImSark/seraph-lib/main/seraph_gif_frames/" .. frameName)
                    if data ~= "" then writefile(`seraph/gifs/{frameName}`, data) end
                end)
            end
            fps.Text = "We're getting things set up for you.. (" .. math.min(i + batchSize - 1, 150) .. "/150)"
            task.wait(0.1)
        end
        writefile("seraph/cache/seraphdata.gif", "<translation=\"completed\">")
        task.wait(0.25)
        tween_service:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Position = UDim2.new(0.5, 0, 0.5, 0) }):Play()
        task.wait(0.5)
    end

    if not isfile("seraph/cache/images.cache") then
        tween_service:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Position = UDim2.new(0.5, 0, 0.1, 0) }):Play()
        local assets = {
            ['von.png'] = 'https://raw.githubusercontent.com/ImSark/seraph-lib/main/seraph_images/image-removebg-preview.png',
            ['icon.jpg'] = 'https://raw.githubusercontent.com/ImSark/seraph-lib/main/seraph_images/icon.jpg',
            ['atom.png'] = 'https://raw.githubusercontent.com/ImSark/seraph-lib/main/seraph_images/atom.png',
            ['ser.png'] = 'https://raw.githubusercontent.com/ImSark/seraph-lib/main/seraph_images/ser.png',
            ['aph.png'] = 'https://raw.githubusercontent.com/ImSark/seraph-lib/main/seraph_images/aph.png',
        }
        local names = {}
        for name in pairs(assets) do insert(names, name) end
        local total = #names
        for i, name in ipairs(names) do
            local data = get(assets[name])
            if data ~= "" then writefile(`seraph/imgs/{name}`, data) end
            fps.Text = "Downloading images.. (" .. i .. "/" .. total .. ")"
            task.wait(0.1)
        end
        writefile("seraph/cache/images.cache", "<translation=\"completed\">")
        task.wait(0.25)
        tween_service:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Position = UDim2.new(0.5, 0, 0.5, 0) }):Play()
        task.wait(0.5)
    end

    for soundPath, soundUrl in pairs({
        ["seraph/sounds/bubble.mp3"] = "https://raw.githubusercontent.com/ImSark/seraph-lib/main/seraph_sounds/gmod_bubble.mp3",
        ["seraph/sounds/bubble2.mp3"] = "https://raw.githubusercontent.com/ImSark/seraph-lib/main/seraph_sounds/gmod_bubble_2.mp3",
        ["seraph/sounds/trident.mp3"] = "https://raw.githubusercontent.com/ImSark/seraph-lib/main/seraph_sounds/trident-new.mp3",
    }) do
        if not isfile(soundPath) then
            local data = get(soundUrl)
            if data ~= "" then writefile(soundPath, data) end
        end
    end

    fps.Text = "Cleaning up..."
    task.wait(0.25)
    isDone = true

    tween_service:Create(fps, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { TextTransparency = 1 }):Play()
    tween_service:Create(icon, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { ImageTransparency = 1 }):Play()
    tween_service:Create(frame, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { BackgroundTransparency = 1 }):Play()
    for _, stroke in frame:GetChildren() do
        if stroke:IsA("UIStroke") then
            tween_service:Create(stroke, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Transparency = 1 }):Play()
        end
    end
    task.wait(1)
    load:Destroy()
end)

repeat task.wait() until isDone

-- ═══════════════════════════════════════════════════════════════
-- LIBRARY INIT
-- ═══════════════════════════════════════════════════════════════

local library = {
    directory = "seraph",
    folders = { "/fonts", "/cfg", "/lua" },
    flags = {},
    config_flags = {},
    connections = {},
    colorpicker_open = false,
    unloaded = false,
}

getgenv().library = library

library.gradientEvent = Instance.new("BindableEvent")
library.gradientChanged = library.gradientEvent.Event
library.guiVisibility = Instance.new("BindableEvent")
library.guiVisibilityChanged = library.guiVisibility.Event
library.font = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Light, Enum.FontStyle.Normal)
library.__index = library

for _, path in next, library.folders do
    pcall(makefolder, library.directory .. path)
end

local flags = library.flags
local config_flags = library.config_flags

-- ── Fonts ──
local fonts = {}; do
    local fallback = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)

    local function Register_Font(Name, Weight, Style, Asset)
        local success, err = pcall(function()
            local fontPath = library.directory .. "/fonts/" .. Asset.Id
            if not isfile(fontPath) then
                local data = game:HttpGet(Asset.Font)
                writefile(fontPath, data)
            end
            local fontMetaPath = library.directory .. "/fonts/" .. Name .. ".font"
            pcall(delfile, Name .. ".font")
            local Data = {
                name = Name,
                faces = { { name = "Regular", weight = Weight, style = Style, assetId = getcustomasset(fontPath) } },
            }
            writefile(fontMetaPath, http_service:JSONEncode(Data))
            return getcustomasset(fontMetaPath)
        end)

        if success then
            return getcustomasset(library.directory .. "/fonts/" .. Name .. ".font")
        else
            warn("[seraph lib] failed to load font: " .. Name .. " | " .. tostring(err))
            pcall(delfile, library.directory .. "/fonts/" .. Asset.Id)
            pcall(delfile, library.directory .. "/fonts/" .. Name .. ".font")
            return nil
        end
    end

    local TahomaBold = Register_Font("TahomaBold", 200, "Normal", {
        Id = "TahomaBold.ttf",
        Font = "https://raw.githubusercontent.com/ImSark/seraph-lib/main/seraph_fonts/tahoma_bold.ttf",
    })
    local ProggyClean = Register_Font("ProggyClean", 200, "normal", {
        Id = "ProggyClean.ttf",
        Font = "https://raw.githubusercontent.com/ImSark/seraph-lib/main/seraph_fonts/ProggyClean.ttf"
    })
    local Pixel = Register_Font("Pixel", 200, "normal", {
        Id = "Pixel.ttf",
        Font = "https://raw.githubusercontent.com/ImSark/seraph-lib/main/seraph_fonts/pixel.ttf"
    })
    local Tahoma = Register_Font("Tahoma", 200, "normal", {
        Id = "Tahoma.ttf",
        Font = "https://raw.githubusercontent.com/ImSark/seraph-lib/main/seraph_fonts/tahoma-bold.ttf"
    })
    local Verdana = Register_Font("Verdana", 200, "normal", {
        Id = "Verdana.ttf",
        Font = "https://raw.githubusercontent.com/ImSark/seraph-lib/main/seraph_fonts/verdana.ttf"
    })
    local Pixel2 = Register_Font("Pixel2", 200, "normal", {
        Id = "Pixel2.ttf",
        Font = "https://raw.githubusercontent.com/ImSark/seraph-lib/main/seraph_fonts/pixelfont.ttf"
    })

    fonts = {
        ["TahomaBold"] = TahomaBold and Font.new(TahomaBold, Enum.FontWeight.Regular, Enum.FontStyle.Normal) or fallback,
        ["ProggyClean"] = ProggyClean and Font.new(ProggyClean, Enum.FontWeight.Regular, Enum.FontStyle.Normal) or fallback,
        ["Pixel"] = Pixel and Font.new(Pixel, Enum.FontWeight.Regular, Enum.FontStyle.Normal) or fallback,
        ["Verdana"] = Verdana and Font.new(Verdana, Enum.FontWeight.Regular, Enum.FontStyle.Normal) or fallback,
        ["Tahoma"] = Tahoma and Font.new(Tahoma, Enum.FontWeight.Regular, Enum.FontStyle.Normal) or fallback,
        ["Pixel2"] = Pixel2 and Font.new(Pixel2, Enum.FontWeight.Regular, Enum.FontStyle.Normal) or fallback,
    }
    library.font = fonts.ProggyClean or fallback
end

-- ── Themes ──
local themes = {
    corners = true,
    preset = {
        outline = rgb(0, 0, 0),
        inline = rgb(14, 14, 14),
        text = rgb(255, 255, 255),
        text_outline = rgb(0, 0, 0),
        background = rgb(15, 15, 15),
        ["1"] = rgb(20, 20, 20),
        ["2"] = rgb(20, 20, 20),
        ["3"] = rgb(20, 20, 20),
        button = seraphAcc.theme and seraphAcc.theme.button or rgb(121, 96, 180),
        button_alt = seraphAcc.theme and seraphAcc.theme.button_alt or rgb(151, 125, 214)
    },
    utility = {
        inline = { BackgroundColor3 = {} },
        text = { TextColor3 = {} },
        text_outline = { Color = {} },
        ["1"] = { BackgroundColor3 = {}, TextColor3 = {}, ImageColor3 = {}, ScrollBarImageColor3 = {} },
        ["2"] = { BackgroundColor3 = {}, TextColor3 = {}, ImageColor3 = {}, ScrollBarImageColor3 = {} },
        ["3"] = { BackgroundColor3 = {}, TextColor3 = {}, ImageColor3 = {}, ScrollBarImageColor3 = {} },
    }
}

-- ── Key display names ──
local keys = {
    [Enum.KeyCode.LeftShift] = "LS", [Enum.KeyCode.RightShift] = "RS",
    [Enum.KeyCode.LeftControl] = "LC", [Enum.KeyCode.RightControl] = "RC",
    [Enum.KeyCode.Insert] = "INS", [Enum.KeyCode.Backspace] = "BS",
    [Enum.KeyCode.Return] = "Ent", [Enum.KeyCode.LeftAlt] = "LA",
    [Enum.KeyCode.RightAlt] = "RA", [Enum.KeyCode.CapsLock] = "CAPS",
    [Enum.KeyCode.One] = "1", [Enum.KeyCode.Two] = "2", [Enum.KeyCode.Three] = "3",
    [Enum.KeyCode.Four] = "4", [Enum.KeyCode.Five] = "5", [Enum.KeyCode.Six] = "6",
    [Enum.KeyCode.Seven] = "7", [Enum.KeyCode.Eight] = "8", [Enum.KeyCode.Nine] = "9",
    [Enum.KeyCode.Zero] = "0",
    [Enum.KeyCode.KeypadOne] = "Num1", [Enum.KeyCode.KeypadTwo] = "Num2",
    [Enum.KeyCode.KeypadThree] = "Num3", [Enum.KeyCode.KeypadFour] = "Num4",
    [Enum.KeyCode.KeypadFive] = "Num5", [Enum.KeyCode.KeypadSix] = "Num6",
    [Enum.KeyCode.KeypadSeven] = "Num7", [Enum.KeyCode.KeypadEight] = "Num8",
    [Enum.KeyCode.KeypadNine] = "Num9", [Enum.KeyCode.KeypadZero] = "Num0",
    [Enum.KeyCode.Minus] = "-", [Enum.KeyCode.Equals] = "=",
    [Enum.KeyCode.Tilde] = "~", [Enum.KeyCode.LeftBracket] = "[",
    [Enum.KeyCode.RightBracket] = "]", [Enum.KeyCode.Semicolon] = ",",
    [Enum.KeyCode.Quote] = "'", [Enum.KeyCode.BackSlash] = "\\",
    [Enum.KeyCode.Comma] = ",", [Enum.KeyCode.Period] = ".",
    [Enum.KeyCode.Slash] = "/", [Enum.KeyCode.Asterisk] = "*",
    [Enum.KeyCode.Plus] = "+", [Enum.KeyCode.Backquote] = "`",
    [Enum.UserInputType.MouseButton1] = "MB1",
    [Enum.UserInputType.MouseButton2] = "MB2",
    [Enum.UserInputType.MouseButton3] = "MB3",
    [Enum.KeyCode.Escape] = "ESC",
    [Enum.KeyCode.Space] = "SPC",
}

-- ═══════════════════════════════════════════════════════════════
-- LIBRARY UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

function library:tween(obj, properties)
    return tween_service:Create(obj, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), properties):Play()
end

function library:close_current_element()
    local path = library.current_element_open
    if path then path.set_visible(false) path.open = false end
end

function library:resizify(frame)
    local btn = Instance.new("TextButton")
    btn.Position = dim2(1, -12, 1, -12)
    btn.Size = dim2(0, 12, 0, 12)
    btn.BorderSizePixel = 0
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Active = false
    btn.Parent = frame

    local indicator = library:create("Frame", {
        Parent = btn, Size = dim2(0, 6, 0, 6),
        Position = dim2(0.5, 0, 0.5, 0), AnchorPoint = vec2(0.5, 0.5),
        BackgroundColor3 = rgb(80, 80, 80), BorderSizePixel = 0, Visible = false
    })
    library:create("UICorner", { Parent = indicator, CornerRadius = dim(0, 1) })

    btn.MouseEnter:Connect(function() indicator.Visible = true end)
    btn.MouseLeave:Connect(function() indicator.Visible = false end)

    local resizing, start, start_size, og_size = false, nil, nil, frame.Size
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true start = input.Position start_size = frame.Size
            indicator.BackgroundColor3 = rgb(121, 96, 180)
        end
    end)
    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = false
            indicator.BackgroundColor3 = rgb(80, 80, 80)
        end
    end)
    library:connection(uis.InputChanged, function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local vp = camera.ViewportSize
            frame.Size = dim2(
                start_size.X.Scale, clamp(start_size.X.Offset + (input.Position.X - start.X), og_size.X.Offset, vp.X),
                start_size.Y.Scale, clamp(start_size.Y.Offset + (input.Position.Y - start.Y), og_size.Y.Offset, vp.Y)
            )
        end
    end)
end

function library:mouse_in_frame(uiobject)
    local ap, as = uiobject.AbsolutePosition, uiobject.AbsoluteSize
    return ap.Y <= mouse.Y and mouse.Y <= ap.Y + as.Y and ap.X <= mouse.X and mouse.X <= ap.X + as.X
end

library.lerp = function(start, finish, t)
    t = t or 1 / 8
    return start * (1 - t) + finish * t
end

function library:draggify(frame, scale)
    scale = scale or 1
    local dragging, start, start_pos = false, nil, nil
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true start = input.Position start_pos = frame.Position
        end
    end)
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    library:connection(uis.InputChanged, function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local vp = camera.ViewportSize
            frame.Position = dim2(
                0, floor(clamp(start_pos.X.Offset + (input.Position.X - start.X), 0, vp.X - frame.Size.X.Offset) / scale) * scale,
                0, floor(clamp(start_pos.Y.Offset + (input.Position.Y - start.Y), 0, vp.Y - frame.Size.Y.Offset) / scale) * scale
            )
        end
    end)
end

function library:convert(str)
    local values = {}
    for value in string.gmatch(str, "[^,]+") do insert(values, tonumber(value)) end
    if #values == 4 then return table.unpack(values) end
end

function library:convert_enum(enumStr)
    local parts = {}
    for part in string.gmatch(enumStr, "[%w_]+") do insert(parts, part) end
    local cur = Enum
    for i = 2, #parts do cur = cur[parts[i]] end
    return cur
end

local config_holder
function library:update_config_list()
    if not config_holder then return end
    local list = {}
    for idx, file in ipairs(listfiles(library.directory .. "/configs") or {}) do
        if not file:match(".cfg") then continue end
        list[#list + 1] = file:gsub(library.directory .. "/configs\\", ""):gsub(".cfg", ""):gsub(library.directory .. "\\cfg\\", "")
    end
    config_holder.refresh_options(list)
end

function library:get_config()
    local Config = {}
    for flag_name, v in pairs(flags) do
        local tv = type(v)
        if tv == "table" and v.key then
            Config[flag_name] = { active = v.active, mode = v.mode, key = tostring(v.key) }
        elseif tv == "table" and v["Color"] then
            Config[flag_name] = {
                Transparency = v["Transparency"] or 0,
                Color = typeof(v["Color"]) == "Color3" and v["Color"]:ToHex() or v["Color"]
            }
        elseif tv == "boolean" or tv == "number" or tv == "string" then
            Config[flag_name] = v
        elseif tv == "table" then
            local clean, isPure = {}, true
            for k, val in pairs(v) do
                local tval = type(val)
                if tval == "userdata" or tval == "function" then isPure = false break end
                clean[k] = val
            end
            if isPure then Config[flag_name] = clean end
        end
    end
    return http_service:JSONEncode(Config)
end

function library:load_config(config_json)
    local config = http_service:JSONDecode(config_json)
    for k, v in next, config do
        pcall(function()
            local fn = library.config_flags[k]
            if k ~= "config_name_list" and fn then
                if type(v) == "table" and v["Transparency"] and v["Color"] then
                    fn(hex(v["Color"]), 1 - v["Transparency"])
                elseif type(v) == "table" and v["active"] and v["mode"] then
                    local key = v.key
                    if type(key) == "string" and key:find("Enum") then
                        key = library:convert_enum(key)
                    end
                    fn({ active = v.active, mode = v.mode, key = key })
                elseif type(v) == "table" and v.active ~= nil and v.mode == nil and v["Color"] == nil then
                    fn(v)
                else
                    fn(v)
                end
            end
        end)
    end
end

function library:save_config(name)
    if not name or name == "" then return end
    writefile(library.directory .. "/configs/" .. name .. ".cfg", library:get_config())
    if config_holder then library:update_config_list() end
end

function library:load_config_file(name)
    if not name or name == "" then return end
    local path = library.directory .. "/configs/" .. name .. ".cfg"
    if not isfile(path) then return end
    library:load_config(readfile(path))
end

function library:delete_config(name)
    if not name or name == "" then return end
    pcall(delfile, library.directory .. "/configs/" .. name .. ".cfg")
    if config_holder then library:update_config_list() end
end

function library:round(number, float)
    float = float or 1
    if float == 0 then return number end
    local m = 1 / float
    return floor(number * m + 0.5) / m
end

function library:apply_theme(instance, theme, property)
    insert(themes.utility[theme][property], instance)
end

function library:update_theme(theme, color)
    for property_name, instances in pairs(themes.utility[theme]) do
        for _, instance in ipairs(instances) do
            instance[property_name] = color
        end
    end
    themes.preset[theme] = color
end

function library:connection(signal, callback)
    local con = signal:Connect(callback)
    insert(library.connections, con)
    return con
end

function library:apply_stroke(parent)
    local s = library:create("UIStroke", { Parent = parent, Color = themes.preset.text_outline, LineJoinMode = Enum.LineJoinMode.Miter })
    library:apply_theme(s, "text_outline", "Color")
    return s
end

function library:create(instance, options)
    local ins = Instance.new(instance)
    for prop, value in next, options do ins[prop] = value end
    if instance == "TextLabel" or instance == "TextButton" or instance == "TextBox" then
        library:apply_theme(ins, "text", "TextColor3")
        library:apply_stroke(ins)
    end
    return ins
end

function library:unload_menu()
    library.unloaded = true
    if library.gui then library.gui:Destroy() end
    for index, connection in next, library.connections do
        pcall(function() connection:Disconnect() end)
    end
    library.connections = {}
    if library.sgui then library.sgui:Destroy() end
    unload_full()
end

function library:get_flag(name)
    return flags[name]
end

function library:set_flag(name, value)
    local fn = config_flags[name]
    if fn then fn(value) end
end

function library:get_all_flags()
    local out = {}
    for k, v in pairs(flags) do
        local tv = type(v)
        if tv ~= "function" and tv ~= "userdata" then
            out[k] = v
        end
    end
    return out
end

local function position_overlay(overlay, anchor, y_offset)
    local pos = anchor.AbsolutePosition
    local size = anchor.AbsoluteSize
    local vp = camera.ViewportSize
    local y = pos.Y + size.Y + (y_offset or 0)
    if y + overlay.AbsoluteSize.Y > vp.Y then
        y = pos.Y - overlay.AbsoluteSize.Y - (y_offset or 0) - 5
    end
    local x = clamp(pos.X, 0, vp.X - overlay.AbsoluteSize.X)
    overlay.Position = dim2(0, x, 0, y)
end

-- ═══════════════════════════════════════════════════════════════
-- TOOLTIP SYSTEM
-- ═══════════════════════════════════════════════════════════════

local show_tooltip
do
    local layover = Instance.new("ScreenGui")
    layover.Name = "layover"
    layover.Parent = gethui()
    layover.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    layover.ResetOnSpawn = false
    layover.DisplayOrder = 100000

    local frame = Instance.new("Frame")
    frame.Name = "frame"
    frame.Parent = layover
    frame.BackgroundColor3 = rgb(20, 20, 20)
    frame.BorderSizePixel = 0
    frame.AutomaticSize = Enum.AutomaticSize.XY

    local label = Instance.new("TextLabel")
    label.Name = "label"
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.BorderSizePixel = 0
    label.FontFace = fonts["ProggyClean"] or Font.new("rbxasset://fonts/families/SourceSansPro.json")
    label.TextColor3 = rgb(255, 255, 255)
    label.TextSize = 12
    label.AutomaticSize = Enum.AutomaticSize.XY

    local pad = Instance.new("UIPadding")
    pad.Parent = frame
    pad.PaddingBottom = UDim.new(0, 7)
    pad.PaddingLeft = UDim.new(0, 7)
    pad.PaddingRight = UDim.new(0, 7)
    pad.PaddingTop = UDim.new(0, 7)

    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = themes.preset.button_alt
    stroke.LineJoinMode = Enum.LineJoinMode.Miter
    stroke.ZIndex = 11

    local grad = Instance.new("UIGradient", stroke)
    grad.Rotation = 90
    grad.Color = rgbseq(rgb(255, 255, 255), rgb(155, 155, 155))

    for i = 1, 10 do
        local s = stroke:Clone()
        s.Parent = frame
        s.Transparency = i / 10
        s.ZIndex -= 1
        s.Thickness = 1 + i / 3
        s.Color = s.Color:Lerp(rgb(), i / 20)
    end

    local grad2 = Instance.new("UIGradient", label)
    grad2.Rotation = 90
    grad2.Color = rgbseq(rgb(255, 255, 255), rgb(155, 155, 155))

    frame.Visible = true
    local scale = Instance.new("UIScale", frame)
    scale.Scale = 0.0

    local tween, current_position
    label:GetPropertyChangedSignal("TextBounds"):Connect(function()
        if current_position then
            frame.Position = UDim2.new(0, current_position.X - label.TextBounds.X / 2, 0, current_position.Y)
        end
    end)

    show_tooltip = function(enabled, text, pos)
        if tween then tween:Cancel() end
        tween = tween_service:Create(scale, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Scale = enabled and 1.0 or 0.0 })
        tween:Play()
        label.Text = text
        frame.Position = UDim2.new(0, pos.X - label.TextBounds.X / 2, 0, pos.Y)
        current_position = pos
    end
end

-- ═══════════════════════════════════════════════════════════════
-- NOTIFICATION SYSTEMS
-- ═══════════════════════════════════════════════════════════════

local notifications = { notifs = {} }
library.sgui = library:create("ScreenGui", { Name = "Notifications", Parent = gethui() })

function notifications:refresh_notifs()
    for i, v in ipairs(notifications.notifs) do
        tween_service:Create(v, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { Position = dim_offset(50, 50 + (i * 30)) }):Play()
    end
end

function notifications:fade(path, fading)
    fading = fading and 1 or 0
    tween_service:Create(path, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { BackgroundTransparency = fading }):Play()
    for _, inst in ipairs(path:GetDescendants()) do
        if inst:IsA("UIStroke") then
            tween_service:Create(inst, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { Transparency = fading }):Play()
        elseif inst:IsA("TextLabel") then
            tween_service:Create(inst, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { TextTransparency = fading }):Play()
        elseif inst:IsA("Frame") then
            tween_service:Create(inst, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { BackgroundTransparency = fading }):Play()
        end
    end
end

function notifications:create_notification(options)
    local outline = library:create("Frame", {
        Parent = library.sgui, Position = dim_offset(-50, 50 + (#notifications.notifs * 30)),
        Size = dim2(0, 0, 0, 24), BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = rgb(255, 255, 255)
    })
    local dark = library:create("Frame", {
        Parent = outline, BackgroundTransparency = 1, Position = dim2(0, 2, 0, 2),
        Size = dim2(1, -4, 1, -4), BorderSizePixel = 0, BackgroundColor3 = rgb(0, 0, 0)
    })
    library:create("UIPadding", { PaddingTop = dim(0, 7), PaddingBottom = dim(0, 6), Parent = dark, PaddingRight = dim(0, 7), PaddingLeft = dim(0, 4) })
    library:create("TextLabel", {
        FontFace = library.font, Text = options.name or "Notification", Parent = dark,
        Size = dim2(0, 0, 1, 0), Position = dim2(0, 1, 0, -1), BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left, BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.X, TextSize = 12,
    })
    library:create("UIGradient", {
        Color = rgbseq{ rgbkey(0, themes.preset["1"]), rgbkey(0.5, themes.preset["2"]), rgbkey(1, themes.preset["3"]) }, Parent = outline
    })
    local index = #notifications.notifs + 1
    notifications.notifs[index] = outline
    notifications:refresh_notifs()
    tween_service:Create(outline, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { AnchorPoint = vec2(0, 0) }):Play()
    notifications:fade(outline, false)
    task.spawn(function()
        task.wait(3)
        notifications.notifs[index] = nil
        notifications:fade(outline, true)
        task.wait(3)
        outline:Destroy()
    end)
end

local fancy_notifications = {}

function createNotification(info)
    local notif = Instance.new("Frame")
    notif.Name = "notif"
    notif.Position = UDim2.new(1, -5, 1, -5)
    notif.Size = UDim2.new(0, 500, 0, 23)
    notif.BackgroundColor3 = rgb(33, 33, 33)
    notif.BorderSizePixel = 0
    notif.AnchorPoint = Vector2.new(1, 1)
    notif.Parent = library.gui

    local holder = Instance.new("Frame")
    holder.Name = "holder"
    holder.Position = UDim2.new(0.5, 0, 0.5, 0)
    holder.Size = UDim2.new(1, -5, 1, -5)
    holder.BackgroundColor3 = rgb(30, 30, 30)
    holder.BorderSizePixel = 0
    holder.AnchorPoint = Vector2.new(0.5, 0.5)
    holder.Parent = notif

    local textContainer = Instance.new("Frame")
    textContainer.Name = "textContainer"
    textContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
    textContainer.Size = UDim2.new(1, -5, 1, -5)
    textContainer.BackgroundTransparency = 1
    textContainer.BorderSizePixel = 0
    textContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    textContainer.Parent = holder

    local start = Instance.new("TextLabel")
    start.Name = "start"
    start.Size = UDim2.new(0, 0, 0, 11)
    start.BackgroundTransparency = 1
    start.BorderSizePixel = 0
    start.AutomaticSize = Enum.AutomaticSize.X
    start.Text = "seraph"
    start.TextColor3 = themes.preset.button_alt
    start.TextSize = 14
    start.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    start.Parent = textContainer

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = textContainer

    local sub = Instance.new("TextLabel")
    sub.Name = "sub"
    sub.Size = UDim2.new(0, 0, 0, 11)
    sub.BackgroundTransparency = 1
    sub.BorderSizePixel = 0
    sub.AutomaticSize = Enum.AutomaticSize.X
    sub.Text = "|"
    sub.TextColor3 = rgb(255, 255, 255)
    sub.TextSize = 14
    sub.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    sub.Parent = textContainer

    local real = Instance.new("TextLabel")
    real.Name = "real"
    real.Size = UDim2.new(0, 0, 0, 11)
    real.BackgroundTransparency = 1
    real.BorderSizePixel = 0
    real.AutomaticSize = Enum.AutomaticSize.X
    real.Text = ""
    real.TextColor3 = rgb(255, 255, 255)
    real.TextSize = 14
    real.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    real.Parent = textContainer

    local strokeColors = {
        rgb(33, 33, 33), rgb(36, 36, 36), rgb(42, 42, 42), rgb(48, 48, 48),
        rgb(54, 54, 54), rgb(60, 60, 60), rgb(66, 66, 66), rgb(72, 72, 72), rgb(78, 78, 78)
    }
    local strokeThicknesses = { 2, 2.5, 3, 3.5, 4, 4.5, 5, 5.5, 6 }
    local strokeTransparencies = { 0.8, 0.85, 0.9, 0.93, 0.95, 0.97, 0.98, 0.99, 0.995 }

    for i = 1, #strokeColors do
        local s = Instance.new("UIStroke")
        s.Name = "border"
        s.Color = strokeColors[i]
        s.Thickness = strokeThicknesses[i]
        s.Transparency = strokeTransparencies[i]
        s.LineJoinMode = Enum.LineJoinMode.Miter
        s.Parent = notif
    end

    local loading = Instance.new("Frame")
    loading.Name = "loading"
    loading.Size = UDim2.new(1, 0, 0, 1)
    loading.BackgroundColor3 = themes.preset.button_alt
    loading.BorderSizePixel = 0
    loading.Parent = notif

    local grad = Instance.new("UIGradient")
    grad.Color = rgbseq(rgb(255, 255, 255), rgb(107, 107, 107))
    grad.Rotation = 90
    grad.Parent = loading

    local scale = Instance.new("UIScale")
    scale.Name = "scale"
    scale.Scale = 0
    scale.Parent = notif

    task.spawn(function()
        if not info.time then info.time = math.clamp((#info.text / 4) / 2, 5, 50) end
        info.text = (info.text or "") .. "   "
        for i = 1, #info.text do
            real.Text = string.sub(info.text, 1, i)
            start.TextColor3 = themes.preset.button_alt
            if i % 4 == 0 then run.RenderStepped:Wait() end
        end
    end)

    if flags.notifSound then
        local bubblePath = isfile("seraph/sounds/bubble.mp3") and getcustomasset("seraph/sounds/bubble.mp3") or "rbxassetid://85730811347567"
        local sound = Instance.new("Sound")
        sound.SoundId = bubblePath
        sound.Volume = 1
        sound.PlayOnRemove = true
        sound.Parent = coregui
        sound:Play()
        task.delay(5, game.Destroy, sound)
    end

    notif.Size = UDim2.new(0, 0, 0, 23)
    scale.Scale = 0

    insert(fancy_notifications, {
        time = info.time or 5,
        totalTime = info.time or info.duration or 5,
        notif = notif,
    })
end

library:connection(run.RenderStepped, function(dt)
    if #fancy_notifications == 0 then return end
    for i = #fancy_notifications, 1, -1 do
        local notifData = fancy_notifications[i]
        local notif = notifData.notif
        notifData.time -= dt

        local textContainer = notif.holder.textContainer
        local totalLength, count = 0, 0
        for _, v in ipairs(textContainer:GetChildren()) do
            if v:IsA("TextLabel") then
                totalLength += v.AbsoluteSize.X
                count += 1
            end
        end
        totalLength += 5 * count - 1

        notif.Size = notif.Size:lerp(UDim2.new(0, totalLength + 2, 0, 23), 0.45)
        notif.loading.Size = UDim2.new(math.lerp(1, 0, 1 - (notifData.time / notifData.totalTime)), 0, 0, 1)

        if notifData.time <= 0 then
            notif.Position = notif.Position:Lerp(UDim2.new(1, -5, 1, 60), 0.35)
            notif.scale.Scale = math.clamp(notif.scale.Scale - dt * 2, 0, 1)
            if notif.scale.Scale <= 0.05 then
                table.remove(fancy_notifications, i)
                notif:Destroy()
            end
        else
            local offset = 0
            for j = i + 1, #fancy_notifications do offset += 1 end
            notif.Position = notif.Position:Lerp(UDim2.new(1, -5, 1, -5 - (35 * offset)), 0.35)
            notif.scale.Scale = math.clamp(notif.scale.Scale + dt * 10, 0, 1)
        end
        notif.Parent = library.gui
    end
end)

library.hitLogGui = library:create("ScreenGui", { Name = "HitLogs", ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = gethui() })
library.logContainer = library:create("Frame", {
    Name = "LogContainer", Size = UDim2.new(0, 0, 1, 0), Position = UDim2.new(0, 10, 0, 0),
    BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X, Parent = library.hitLogGui
})
library:create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2), Parent = library.logContainer })
library.activeNotifications = 0

function library:spawnLog(text)
    local logFrame = library:create("Frame", {
        Name = "LogFrame", Size = UDim2.new(0, 0, 0, 22), BackgroundColor3 = rgb(32, 32, 32),
        BackgroundTransparency = 0.5, AutomaticSize = Enum.AutomaticSize.X, BorderSizePixel = 0, Parent = library.logContainer
    })
    local scale = library:create("UIScale", { Parent = logFrame, Scale = 0 })
    tween_service:Create(scale, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { Scale = 1 }):Play()

    library.activeNotifications += 1
    local notifId = library.activeNotifications

    library:create("UIPadding", { PaddingTop = UDim.new(0, 1), PaddingBottom = UDim.new(0, 1), PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 64), Parent = logFrame })
    library:create("UIGradient", { Transparency = numseq{ numkey(0, 0), numkey(0.0822943, 0), numkey(0.366584, 0.0375), numkey(0.51995, 0.19375), numkey(0.75187, 0.2875), numkey(0.840399, 0.66875), numkey(0.9202, 0.85625), numkey(1, 1) }, Parent = logFrame })

    local textLabel = library:create("TextLabel", {
        Name = "Segments", Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 3, 0, 0),
        BackgroundTransparency = 1, TextStrokeTransparency = 1, ZIndex = 5, AutomaticSize = Enum.AutomaticSize.X,
        Text = text, TextColor3 = rgb(255, 255, 255), TextSize = 12, RichText = true, FontFace = fonts.ProggyClean or library.font, Parent = logFrame
    })

    local accentBar = library:create("Frame", {
        Name = "AccentBar", Position = UDim2.new(0, -6, 0, 0), Size = UDim2.new(0, 8, 1, 0),
        BackgroundColor3 = themes.preset.button_alt, BorderSizePixel = 0, LayoutOrder = 3, Parent = logFrame
    })
    library:create("UIGradient", {
        Color = rgbseq(rgb(255, 255, 255), rgb(0, 0, 0)),
        Transparency = numseq{ numkey(0, 0), numkey(0.527431, 0), numkey(0.599751, 1), numkey(1, 1) }, Parent = accentBar
    })

    task.spawn(function()
        run.RenderStepped:Wait()
        local timeWaiting = 7
        repeat timeWaiting -= run.RenderStepped:Wait() until timeWaiting <= 0 or (library.activeNotifications - notifId) > 20
        library.activeNotifications -= 1
        tween_service:Create(accentBar, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { BackgroundTransparency = 1 }):Play()
        tween_service:Create(logFrame, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { BackgroundTransparency = 1 }):Play()
        tween_service:Create(textLabel, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { TextTransparency = 1 }):Play()
        tween_service:Create(textLabel, TweenInfo.new(1.05, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { Position = UDim2.new(-2, 0, 0) }):Play()
        task.delay(1.0, game.Destroy, logFrame)
    end)
end

function library:watermark(options)
    local outline = library:create("Frame", {
        Parent = library.sgui, Position = dim2(0, 50, 0, 50), Size = dim2(0, 0, 0, 24),
        BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = rgb(255, 255, 255)
    })
    library.watermark_outline = outline
    library:draggify(outline)

    local dark = library:create("Frame", {
        Parent = outline, BackgroundTransparency = 0.6, Position = dim2(0, 2, 0, 2),
        Size = dim2(1, -4, 1, -4), BorderSizePixel = 0, BackgroundColor3 = rgb(0, 0, 0)
    })
    library:create("UIPadding", { PaddingTop = dim(0, 7), PaddingBottom = dim(0, 6), Parent = dark, PaddingRight = dim(0, 7), PaddingLeft = dim(0, 4) })

    local text_title = library:create("TextLabel", {
        FontFace = library.font, Text = options.name or "library", Parent = dark,
        Size = dim2(0, 0, 1, 0), Position = dim2(0, 1, 0, -1), BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left, BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.X, TextSize = 12,
    })
    library:create("UIGradient", {
        Color = rgbseq{ rgbkey(0, themes.preset["1"]), rgbkey(0.5, themes.preset["2"]), rgbkey(1, themes.preset["3"]) }, Parent = outline
    })
    return setmetatable({ update_text = function(t) text_title.Text = t end }, library)
end

-- ═══════════════════════════════════════════════════════════════
-- TWEEN ANIMATION SYSTEM
-- ═══════════════════════════════════════════════════════════════

library.animations = {}
function library:create_tween(obj, info, prop)
    if library.animations[obj] then
        library.animations[obj]:Cancel()
        library.animations[obj] = nil
    end
    local t = tween_service:Create(obj, TweenInfo.new(table.unpack(info)), prop)
    t:Play()
    library.animations[obj] = t
    return t
end

-- ═══════════════════════════════════════════════════════════════
-- UI ELEMENTS
-- ═══════════════════════════════════════════════════════════════

function library:window(properties)
    local cfg = {
        name = properties.name or properties.Name or "library",
        size = properties.size or properties.Size or dim2(0, 460, 0, 362),
        selected_tab = nil,
        tabs = {},
    }

    library.gui = library:create("ScreenGui", {
        Parent = coregui, Name = "\0", Enabled = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true, DisplayOrder = 9e4
    })

    local scale = library:create("UIScale", { Parent = library.gui })
    library.gui_scale = 1
    library.main_scale = scale
    pcall(function() library.gui_scale = tonumber(readfile("seraph/configs/default_scale.value")) end)

    local tween, info = nil, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    library.gui_visible = true
    library.guiVisibility:Fire(library.gui_visible)

    library:connection(uis.InputBegan, function(input, gpe)
        if not gpe and (input.KeyCode == Enum.KeyCode.Delete or input.KeyCode == Enum.KeyCode.Home) and not guiDebounce then
            library:set_visibility()
        end
    end)

    function library:set_visibility()
        if tween then tween:Cancel() end
        guiDebounce = true
        tween = tween_service:Create(scale, info, { Scale = library.gui_visible and 0 or library.gui_scale })
        tween:Play()
        library.gui_visible = not library.gui_visible
        writefile("seraph/configs/default_scale.value", tostring(library.gui_scale))
        library.guiVisibility:Fire(library.gui_visible)
        task.wait(0.15)
        guiDebounce = false
    end

    local window_outline = library:create("Frame", {
        Parent = library.gui,
        Position = dim2(0.5, -cfg.size.X.Offset / 2, 0.5, -cfg.size.Y.Offset / 2),
        Size = cfg.size, BorderSizePixel = 0, BackgroundColor3 = rgb(255, 255, 255)
    })

    function library:set_scale(val)
        library.gui_scale = val
        if tween then tween:Cancel() end
        scale.Scale = library.gui_visible and val or 0
    end

    task.delay(0.1, function()
        tween = tween_service:Create(scale, info, { Scale = library.gui_scale })
        tween:Play()
    end)

    library:create("ImageLabel", {
        Name = "glow", Image = "rbxassetid://18245826428",
        BackgroundTransparency = 1, ImageColor3 = rgb(), ZIndex = -1, ImageTransparency = 0.8,
        Size = UDim2.new(1, 40, 1, 40), Position = UDim2.new(0, -20, 0, -20),
        ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(21, 21, 79, 79), Parent = window_outline
    })

    library.main_frame = window_outline
    if themes.corners then
        library:create("UICorner", { Parent = window_outline, CornerRadius = UDim.new(0, 2) })
        scale.Parent = window_outline
    end

    cfg.main_outline = window_outline
    library:resizify(window_outline)
    library:draggify(window_outline)

    local title_holder = library:create("Frame", {
        Parent = window_outline, BackgroundTransparency = 0.8, Position = dim2(0, 2, 0, 2),
        Size = dim2(1, -4, 0, 20), BorderSizePixel = 0, BackgroundColor3 = rgb(0, 0, 0)
    })

    local ui_title = library:create("TextLabel", {
        FontFace = fonts["TahomaBold"] or library.font, Text = cfg.name, Parent = title_holder,
        BackgroundTransparency = 1, Size = dim2(1, 0, 1, 0), BorderSizePixel = 0,
        TextSize = 12, RichText = true,
    })

    function cfg:set_title(t) ui_title.Text = t end

    library.gradient = library:create("UIGradient", {
        Color = rgbseq{ rgbkey(0, themes.preset["1"]), rgbkey(0.5, themes.preset["2"]), rgbkey(1, themes.preset["3"]) },
        Parent = window_outline
    })

    local tab_button_holder = library:create("Frame", {
        AnchorPoint = vec2(0, 1), Parent = window_outline, BackgroundTransparency = 0.8,
        Position = dim2(0, 2, 1, -2), Size = dim2(1, -4, 0, 20), BorderSizePixel = 0, BackgroundColor3 = rgb(0, 0, 0)
    })
    cfg.tab_button_holder = tab_button_holder

    library:create("UIListLayout", {
        VerticalAlignment = Enum.VerticalAlignment.Center, FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center, HorizontalFlex = Enum.UIFlexAlignment.Fill,
        Parent = tab_button_holder, SortOrder = Enum.SortOrder.LayoutOrder, VerticalFlex = Enum.UIFlexAlignment.Fill
    })

    function cfg:select_tab(tab_name)
        local tab = cfg.tabs[tab_name]
        if tab then tab.open_tab() end
    end

    return setmetatable(cfg, library)
end

function library:tab(properties)
    local cfg = {
        name = properties.name or "tab", count = 0,
        on_click = properties.on_click or function() end, visible = true,
    }

    -- FIX: remove AutomaticSize, let UIListLayout HorizontalFlex handle width
    local tab_button = library:create("TextButton", {
        FontFace = library.font, Text = '', Parent = self.tab_button_holder,
        BackgroundTransparency = 0, BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, 0),
        TextSize = 12, BackgroundColor3 = rgb(255, 255, 255), AutoButtonColor = false,
    })
    library:create("TextLabel", {
        FontFace = library.font, Size = UDim2.new(1, 0, 1, 0), Text = cfg.name,
        Parent = tab_button, BackgroundTransparency = 1, BorderSizePixel = 0,
        TextSize = 12, BackgroundColor3 = rgb(255, 255, 255)
    })
    library:create("UIGradient", {
        Color = rgbseq{ rgbkey(0, themes.preset["1"]:lerp(rgb(), .3)), rgbkey(1, themes.preset["2"]) },
        Rotation = 90, Parent = tab_button
    })

    -- FIX: start visible so AutomaticSize calculates, defer hiding
    local Page = library:create("Frame", {
        Parent = self.main_outline, BackgroundTransparency = 0.6, Position = dim2(0, 2, 0, 24),
        Size = dim2(1, -4, 1, -48), BorderSizePixel = 0, BackgroundColor3 = rgb(0, 0, 0), Visible = true,
    })
    cfg.page = Page

    library:create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal, HorizontalFlex = Enum.UIFlexAlignment.Fill,
        Parent = Page, Padding = dim(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, VerticalFlex = Enum.UIFlexAlignment.Fill
    })
    library:create("UIPadding", {
        PaddingTop = dim(0, 2), PaddingBottom = dim(0, 2), Parent = Page, PaddingRight = dim(0, 2), PaddingLeft = dim(0, 2)
    })

    function cfg.open_tab()
        if self.selected_tab then
            self.selected_tab[1].Visible = false
            self.selected_tab[2].TextColor3 = rgb(170, 170, 170)
        end
        Page.Visible = true
        tab_button.TextColor3 = rgb(255, 255, 255)
        self.selected_tab = { Page, tab_button }
        cfg.on_click()
    end

    function cfg.change_visibility(_, vis) tab_button.Visible = vis cfg.visible = vis end

    tab_button.MouseButton1Down:Connect(function() cfg.open_tab() end)
    
    -- FIX: defer hiding non-selected tabs so AutomaticSize fires
    if not self.selected_tab then
        cfg.open_tab(true)
    else
        task.defer(function()
            Page.Visible = false
        end)
    end

    self.tabs[cfg.name] = cfg
    return setmetatable(cfg, library)
end

function library:column(properties)
    self.count += 1
    local cfg = { color = library.gradient.Color.Keypoints[self.count].Value, count = self.count }

    local scrolling_frame = library:create("ScrollingFrame", {
        ScrollBarImageColor3 = rgb(0, 0, 0), Active = true, AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 0, Parent = self.page, LayoutOrder = -1, BackgroundTransparency = 1,
        ScrollBarImageTransparency = 1, BackgroundColor3 = rgb(0, 0, 0), BorderSizePixel = 0, CanvasSize = dim2(0, 0, 0, 0)
    })
    cfg.column = scrolling_frame

    function cfg:destroy() self.count -= 1 scrolling_frame:Destroy() table.clear(cfg) end

    library:create("UIListLayout", { Parent = scrolling_frame, Padding = dim(0, 5), SortOrder = Enum.SortOrder.LayoutOrder })
    return setmetatable(cfg, library)
end

function library:multisection(properties)
    local cfg = {
        name = properties.name or "multisection", sections = properties.sections or { "tab" },
        size = properties.size or 1, autofill = properties.auto_fill or false, count = self.count,
        color = self.color, tabs = {}, active_tab = nil
    }

    local accent = library:create("Frame", {
        Parent = self.column, ClipsDescendants = true, BorderSizePixel = 0, BackgroundColor3 = self.color,
        Size = cfg.autofill and dim2(1, 0, cfg.size, 0) or dim2(1, 0, 0, 0),
    })
    library:apply_theme(accent, tostring(self.count), "BackgroundColor3")
    library:create("UICorner", { Parent = accent, CornerRadius = dim(0, 2) })

    local tab_holder = library:create("Frame", {
        Parent = accent, Size = dim2(1, 0, 0, 18), BackgroundTransparency = 1, BorderSizePixel = 0, Active = false
    })
    library:create("UIListLayout", {
        Parent = tab_holder, FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = dim(0, 0)
    })

    local sliding_bar = library:create("Frame", {
        Parent = tab_holder, Size = dim2(1 / #cfg.sections, 0, 0, 1),
        Position = dim2(1 - (1 / #cfg.sections * #cfg.sections), 0, 1, -1),
        BackgroundColor3 = self.color, BorderSizePixel = 0, ZIndex = 5, Active = false
    })
    library:apply_theme(sliding_bar, tostring(self.count), "BackgroundColor3")

    local dark = library:create("Frame", {
        Parent = accent, BackgroundTransparency = 0.6, Position = dim2(0, 2, 0, 19),
        Size = dim2(1, -4, 0, 0), BorderSizePixel = 0, ClipsDescendants = true, BackgroundColor3 = rgb(0, 0, 0)
    })
    library:create("UICorner", { Parent = dark, CornerRadius = dim(0, 2) })

    for i, tab_name in ipairs(cfg.sections) do
        local but = library:create("TextButton", {
            Parent = tab_holder, Size = dim2(1 / #cfg.sections, 0, 1, 0), BackgroundTransparency = 1,
            Text = tab_name:lower(), TextColor3 = (i == 1) and rgb(255, 255, 255) or rgb(155, 155, 155),
            FontFace = fonts["TahomaBold"] or library.font, TextSize = 12, AutoButtonColor = false, BorderSizePixel = 0
        })

        local content = library:create("Frame", {
            Parent = dark, Size = dim2(1, 0, 1, 0), Position = dim2(i == 1 and 0 or 1, 0, 0, 0),
            BackgroundTransparency = 1, Visible = (i == 1), Active = false
        })
        local padding_cont = library:create("Frame", {
            Parent = content, Size = dim2(1, -10, 0, 0), Position = dim2(0, 5, 0, 5),
            BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y, Active = false
        })
        local layout = library:create("UIListLayout", { Parent = padding_cont, Padding = dim(0, 6), SortOrder = Enum.SortOrder.LayoutOrder })

        local function update_height()
            if cfg.active_tab == tab_name then
                local h = math.ceil(layout.AbsoluteContentSize.Y) + 10
                dark.Size = dim2(1, -4, 0, h)
                accent.Size = dim2(1, 0, 0, h + 21)
            end
        end
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update_height)

        local tab_api = setmetatable({
            elements = padding_cont, button = but, index = i, container = content,
            update_height = update_height, column = self.column, count = self.count, color = self.color
        }, { __index = library })
        cfg.tabs[tab_name] = tab_api

        local tween, busy = nil, 0
        but.MouseButton1Click:Connect(function()
            if cfg.active_tab == tab_name or busy > 0 then return end
            cfg.active_tab = tab_name
            local target_tab = cfg.tabs[tab_name]
            local t_info = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

            local bar_x = 1 - ((#cfg.sections - i + 1) * (1 / #cfg.sections))
            tween_service:Create(sliding_bar, t_info, { Position = dim2(bar_x, 0, 1, -1) }):Play()
            busy += 3

            for _, t in pairs(cfg.tabs) do
                local is_active = (t == target_tab)
                local target_x = (t.index < target_tab.index) and -1 or (t.index > target_tab.index) and 1 or 0
                if is_active then t.container.Visible = true end
                tween = tween_service:Create(t.container, t_info, { Position = dim2(target_x, 0, 0, 0) })
                tween:Play()
                tween.Completed:Connect(function()
                    if not is_active then t.container.Visible = false end
                    busy -= 1
                end)
                tween_service:Create(t.button, TweenInfo.new(0.25), { TextColor3 = is_active and rgb(255, 255, 255) or rgb(155, 155, 155) }):Play()
            end
            update_height()
        end)

        if i == 1 then cfg.active_tab = tab_name end
    end

    task.spawn(function()
        task.wait()
        if cfg.active_tab and cfg.tabs[cfg.active_tab] then cfg.tabs[cfg.active_tab].update_height() end
    end)

    function cfg:get_tab(name) return cfg.tabs[name] end
    return cfg
end

function library:section(properties)
    local cfg = {
        name = properties.name or properties.Name or "section", size = properties.size or 1,
        autofill = properties.auto_fill or false, count = self.count, color = self.color,
    }

    local accent = library:create("Frame", {
        Parent = self.column, ClipsDescendants = true, BorderSizePixel = 0, BackgroundColor3 = self.color
    })
    library:apply_theme(accent, tostring(self.count), "BackgroundColor3")

    function cfg.show_element(bool) accent.Visible = bool end
    function cfg:destroy() accent:Destroy() table.clear(cfg) end

    local dark = library:create("Frame", {
        Parent = accent, BackgroundTransparency = 0.6, Position = dim2(0, 2, 0, 16),
        Size = dim2(1, -4, 1, -18), BorderSizePixel = 0, BackgroundColor3 = rgb(0, 0, 0), Active = false
    })
    if themes.corners then library:create("UICorner", { Parent = accent, CornerRadius = UDim.new(0, 2) }) end

    local elements = library:create("Frame", {
        Parent = dark, Position = dim2(0, 4, 0, 5), Size = dim2(1, -8, 0, 0),
        BackgroundTransparency = 1, BorderSizePixel = 0, BackgroundColor3 = rgb(255, 255, 255), Active = false
    })
    cfg.elements = elements

    if not cfg.autofill then
        elements.AutomaticSize = Enum.AutomaticSize.Y
        accent.AutomaticSize = Enum.AutomaticSize.Y
        accent.Size = dim2(1, 0, 0, 0)
        library:create("UIPadding", { Parent = elements, PaddingBottom = dim(0, 7) })
    else
        accent.Size = dim2(1, 0, cfg.size, 0)
    end

    library:create("UIListLayout", { Parent = elements, Padding = dim(0, 6), SortOrder = Enum.SortOrder.LayoutOrder })

    local title = library:create("TextLabel", {
        FontFace = fonts["TahomaBold"] or library.font, Text = cfg.name, Parent = accent, Size = dim2(1, 0, 0, 0),
        Position = dim2(0, 4, 0, 1), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left,
        BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.Y, TextSize = 12, BackgroundColor3 = rgb(255, 255, 255)
    })
    function cfg.set_title(_, t) title.Text = t end

    return setmetatable(cfg, library)
end

function library:label(options)
    local cfg = { name = options.name or "Label", popout = options.popout or false, wip = options.wip, beta = options.beta, color = self.color }
    local is_beta = seraphAcc.role == "contributor" or seraphAcc.role == "beta"
    local clr = options.unsafe and rgb(210, 215, 192) or rgb(255, 255, 255)
    if is_beta and cfg.beta then clr = hex("#e67e22") elseif not is_beta and cfg.beta then clr = hex("#e67e22"):lerp(rgb(0, 0, 0), .2) end

    local label_element = library:create("Frame", { Parent = self.elements, BackgroundTransparency = 1, Size = dim2(1, 0, 0, 12), BorderSizePixel = 0, Active = false })
    cfg.instance = label_element

    local nameplate = library:create("TextLabel", {
        FontFace = library.font, TextColor3 = clr, Text = cfg.name, Parent = label_element,
        Size = dim2(0, 0, 1, 0), Position = dim2(0, 1, 0, -1), BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left, BorderSizePixel = 0,
        TextTransparency = (options.wip or (not is_beta and cfg.beta)) and 0.5 or 0,
        AutomaticSize = Enum.AutomaticSize.X, TextSize = 12,
    })

    if options.tip then
        local question = library:create("TextLabel", {
            FontFace = library.font, Text = '?', Parent = nameplate, Size = dim2(0, 0, 1, 0),
            Position = dim2(1, 3, 0, -3), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left,
            TextSize = 8, TextColor3 = clr,
        })
        question.MouseEnter:Connect(function() show_tooltip(true, options.tip, question.AbsolutePosition - vec2(0, 30)) end)
        question.MouseLeave:Connect(function() show_tooltip(false, options.tip, question.AbsolutePosition - vec2(0, 30)) end)
    end

    local right_holder = library:create("Frame", { Parent = label_element, Size = dim2(1, 0, 1, 0), BackgroundTransparency = 1, Active = false })
    library:create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, Parent = right_holder, Padding = dim(0, 4), SortOrder = Enum.SortOrder.LayoutOrder })

    local popout_elements
    if cfg.popout then
        local gear = library:create("ImageButton", {
            Name = "Gear", Parent = right_holder, Size = dim2(0, 14, 0, 14), Position = dim2(0, 0, -3, 0),
            BackgroundTransparency = 1, Image = "rbxassetid://7059346373", ImageColor3 = rgb(200, 200, 200), LayoutOrder = 1, Active = false
        })
        popout_elements = library:create("Frame", {
            Name = "PopoutMenu", Parent = library.gui, BackgroundColor3 = rgb(1, 1, 1), BorderColor3 = self.color,
            BorderSizePixel = 1, Position = dim2(1, 10, 0, 0), Size = dim2(0, 160, 0, 0), Visible = false,
            AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 100, Active = true
        })
        local scale = library:create("UIScale", { Parent = popout_elements, Scale = 0.0 })
        library:create("UIListLayout", { Parent = popout_elements, Padding = dim(0, 6), HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder })
        library:create("UICorner", { Parent = popout_elements, CornerRadius = dim(0, 4) })
        local stroke = library:create("UIStroke", { Parent = popout_elements, Color = themes.preset.button_alt, Thickness = 1 })
        library:create("UIPadding", { Parent = popout_elements, PaddingTop = dim(0, 4), PaddingBottom = dim(0, 4), PaddingLeft = dim(0, 4), PaddingRight = dim(0, 4) })

        local visible = false
        local function update_position()
            popout_elements.Position = dim2(0, label_element.AbsolutePosition.X + label_element.AbsoluteSize.X / 2, 0, label_element.AbsolutePosition.Y + label_element.AbsoluteSize.Y * 2 + 60)
        end
        local tween, scale_tween
        local function animate()
            if tween then tween:Cancel() end
            if scale_tween then scale_tween:Cancel() end
            stroke.Color = visible and themes.preset.button or themes.preset.button_alt
            tween = tween_service:Create(gear, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Rotation = visible and 90 or 0, ImageTransparency = visible and 0 or 0.5 })
            tween:Play()
            scale_tween = tween_service:Create(scale, TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut), { Scale = visible and 1 or 0 })
            scale_tween:Play()
        end
        animate()

        local mouse_con, loop_con
        gear.MouseButton1Click:Connect(function()
            update_position()
            visible = not visible
            popout_elements.Visible = true
            animate()
            if not visible then return end
            if mouse_con then mouse_con:Disconnect() end
            if loop_con then loop_con:Disconnect() end
            mouse_con = uis.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 and not library:mouse_in_frame(popout_elements) and not library:mouse_in_frame(gear) then
                    visible = false if mouse_con then mouse_con:Disconnect() mouse_con = nil end animate()
                end
            end)
            loop_con = run.RenderStepped:Connect(function()
                if not visible then if loop_con then loop_con:Disconnect() loop_con = nil end return end
                if not library.gui_visible then loop_con:Disconnect() loop_con = nil visible = false if mouse_con then mouse_con:Disconnect() mouse_con = nil end animate() return end
                update_position()
            end)
        end)
    end

    function cfg:add(el) if typeof(el) == "table" then el = el.instance end if popout_elements and el then el.Parent = popout_elements end return el end
    function cfg:set_text(v) nameplate.Text = v end
    function cfg.show_element(bool) label_element.Visible = bool end

    return setmetatable(cfg, library)
end

function library:toggle(options)
    local cfg = {
        enabled = options.enabled or nil, name = options.name or "Toggle",
        flag = options.flag or tostring(random(1, 9999999)), default = options.default or false,
        popout = options.popout or false, wip = options.wip, beta = options.beta,
        callback = options.callback or function() end, color = self.color, count = self.count,
    }

    local is_beta = seraphAcc.role == "contributor" or seraphAcc.role == "beta"
    local clr = options.unsafe and rgb(210, 215, 192) or rgb(255, 255, 255)
    if is_beta and cfg.beta then clr = hex("#e67e22") elseif not is_beta and cfg.beta then clr = hex("#e67e22"):lerp(rgb(0, 0, 0), .2) end

    local toggle = library:create("TextButton", {
        Parent = self.elements, BackgroundTransparency = 1, Text = "", Size = dim2(1, 0, 0, 12), BorderSizePixel = 0, AutoButtonColor = false,
    })
    cfg.instance = toggle

    local nameplate = library:create("TextLabel", {
        FontFace = library.font, TextColor3 = clr, Text = cfg.name, Parent = toggle,
        Size = dim2(0, 0, 1, 0), Position = dim2(0, 1, 0, -1), BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left, BorderSizePixel = 0,
        TextTransparency = (options.wip or (not is_beta and cfg.beta)) and 0.5 or 0,
        AutomaticSize = Enum.AutomaticSize.X, TextSize = 12, Active = false,
    })

    if options.tip then
        local question = library:create("TextLabel", {
            FontFace = library.font, Text = '?', Parent = nameplate, Size = dim2(0, 0, 1, 0),
            Position = dim2(1, 3, 0, -3), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left,
            TextSize = 8, TextColor3 = clr, Active = false,
        })
        question.MouseEnter:Connect(function() show_tooltip(true, options.tip, question.AbsolutePosition - vec2(0, 30)) end)
        question.MouseLeave:Connect(function() show_tooltip(false, options.tip, question.AbsolutePosition - vec2(0, 30)) end)
    end

    local right_holder = library:create("Frame", { Parent = toggle, Size = dim2(1, 0, 1, 0), BackgroundTransparency = 1, Active = false })
    library:create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, Parent = right_holder, Padding = dim(0, 4), SortOrder = Enum.SortOrder.LayoutOrder })

    local popout_elements
    if cfg.popout then
        local gear = library:create("ImageButton", {
            Name = "Gear", Parent = right_holder, Size = dim2(0, 14, 0, 14), Position = dim2(0, 0, -3, 0),
            BackgroundTransparency = 1, Image = "rbxassetid://7059346373", ImageColor3 = rgb(200, 200, 200), LayoutOrder = 1, Active = false
        })
        popout_elements = library:create("Frame", {
            Name = "PopoutMenu", Parent = library.gui, BackgroundColor3 = rgb(1, 1, 1), BorderColor3 = self.color,
            BorderSizePixel = 1, Position = dim2(1, 10, 0, 0), Size = dim2(0, 160, 0, 0), Visible = false,
            AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 100, Active = true
        })
        local scale = library:create("UIScale", { Parent = popout_elements, Scale = 0.0 })
        library:create("UIListLayout", { Parent = popout_elements, Padding = dim(0, 6), HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder })
        library:create("UICorner", { Parent = popout_elements, CornerRadius = dim(0, 4) })
        local stroke = library:create("UIStroke", { Parent = popout_elements, Color = themes.preset.button_alt, Thickness = 1 })
        library:create("UIPadding", { Parent = popout_elements, PaddingTop = dim(0, 4), PaddingBottom = dim(0, 4), PaddingLeft = dim(0, 4), PaddingRight = dim(0, 4) })

        local visible = false
        local function update_position()
            popout_elements.Position = dim2(0, toggle.AbsolutePosition.X + toggle.AbsoluteSize.X / 2, 0, toggle.AbsolutePosition.Y + toggle.AbsoluteSize.Y * 2 + 60)
        end
        local tween, scale_tween
        local function animate()
            if tween then tween:Cancel() end
            if scale_tween then scale_tween:Cancel() end
            stroke.Color = visible and themes.preset.button or themes.preset.button_alt
            tween = tween_service:Create(gear, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Rotation = visible and 90 or 0, ImageTransparency = visible and 0 or 0.5 })
            tween:Play()
            scale_tween = tween_service:Create(scale, TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut), { Scale = visible and 1 or 0 })
            scale_tween:Play()
        end
        animate()

        local mouse_con, loop_con
        gear.MouseButton1Click:Connect(function()
            update_position()
            visible = not visible
            popout_elements.Visible = true
            animate()
            if not visible then
                if mouse_con then mouse_con:Disconnect() end
                if loop_con then loop_con:Disconnect() end
                return
            end
            mouse_con = uis.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 and not library:mouse_in_frame(popout_elements) and not library:mouse_in_frame(gear) then
                    visible = false if mouse_con then mouse_con:Disconnect() mouse_con = nil end animate()
                end
            end)
            loop_con = run.RenderStepped:Connect(function()
                if not visible then if loop_con then loop_con:Disconnect() loop_con = nil end return end
                if not library.gui_visible then loop_con:Disconnect() loop_con = nil visible = false if mouse_con then mouse_con:Disconnect() mouse_con = nil end animate() return end
                update_position()
            end)
        end)
    end

    local accent = library:create("TextButton", {
        Parent = right_holder, Size = dim2(0, 12, 0, 12), BorderSizePixel = 0, BackgroundColor3 = self.color, LayoutOrder = 2, Text = "", AutoButtonColor = false,
    })
    library:apply_theme(accent, tostring(self.count), "BackgroundColor3")

    local fill = library:create("Frame", { Parent = accent, Position = dim2(0, 1, 0, 1), Size = dim2(1, -2, 1, -2), BorderSizePixel = 0, BackgroundColor3 = self.color, ClipsDescendants = true, Active = false })
    library:apply_theme(fill, tostring(self.count), "BackgroundColor3")

    local c = (options.wip or (not is_beta and cfg.beta)) and 0.5 or 0.0
    library:create("UIGradient", {
        Parent = fill, Rotation = 90, Transparency = NumberSequence.new(math.lerp(c, 0, 0.25), c),
        Color = rgbseq(rgb(255, 255, 255), rgb(155, 155, 155), rgb(155, 155, 155), rgb(177, 177, 177), rgb(55, 55, 55))
    })

    function cfg.set(bool)
        if cfg.wip or (cfg.beta and not is_beta) then return end
        local backgroundColor3 = bool and themes.preset.button or themes.preset.inline
        fill:SetAttribute("buttonPrimary", bool)
        fill.BackgroundColor3 = backgroundColor3
        fill.BackgroundTransparency = bool and 0 or 1
        flags[cfg.flag] = bool
        cfg.enabled = bool
        cfg.callback(bool)
    end

    function cfg.show_element(bool) toggle.Visible = bool end
    function cfg.set_value(bool) cfg.set(bool) end

    local function on_click()
        cfg.set(not cfg.enabled)
    end
    toggle.MouseButton1Click:Connect(on_click)
    accent.MouseButton1Click:Connect(on_click)

    function cfg:add(el) if typeof(el) == "table" then el = el.instance end if popout_elements and el then el.Parent = popout_elements end end

    library.config_flags[cfg.flag] = cfg.set_value
    cfg.set(cfg.default)
    return setmetatable(cfg, library)
end

function library:list(options)
    local cfg = {
        callback = options and options.callback or function() end, name = options.name or nil,
        scale = options.size or 90, items = options.items or { "1", "2", "3" }, visible = options.visible or true,
        option_instances = {}, current_instance = nil, flag = options.flag or "SET A FLAG",
    }

    local accent = library:create("Frame", {
        BorderColor3 = rgb(0, 0, 0), AnchorPoint = vec2(1, 0), Parent = self.elements, Position = dim2(1, 0, 0, 0),
        Size = dim2(1, 0, 0, cfg.scale), BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = self.color, Active = false
    })
    library:apply_theme(accent, tostring(self.count), "BackgroundColor3")

    function cfg:destroy() accent:Destroy() table.clear(cfg) end
    function cfg.show_element(bool) accent.Visible = bool end

    local inline = library:create("Frame", { Parent = accent, Position = dim2(0, 1, 0, 1), Size = dim2(1, -2, 1, -2), BorderSizePixel = 0, BackgroundColor3 = themes.preset.inline, Active = false })
    library:apply_theme(inline, "inline", "BackgroundColor3")

    local scrollingframe = library:create("ScrollingFrame", {
        ScrollBarImageColor3 = rgb(0, 0, 0), Active = true, AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 0, Parent = inline, Size = dim2(1, 0, 1, 0), LayoutOrder = -1,
        BackgroundTransparency = 1, ScrollBarImageTransparency = 1, BackgroundColor3 = rgb(0, 0, 0), BorderSizePixel = 0, CanvasSize = dim2(0, 0, 0, 0)
    })
    library:create("UIGradient", { Parent = inline, Rotation = 90, Color = rgbseq(rgb(255, 255, 255), rgb(188, 188, 188)) })
    library:create("UIListLayout", { Parent = scrollingframe, Padding = dim(0, 6), SortOrder = Enum.SortOrder.LayoutOrder })
    library:create("UIPadding", { PaddingTop = dim(0, 2), PaddingBottom = dim(0, 4), Parent = scrollingframe, PaddingRight = dim(0, 5), PaddingLeft = dim(0, 5) })

    function cfg.render_option(text)
        return library:create("TextButton", {
            FontFace = library.font, TextColor3 = rgb(170, 170, 170), Text = text, AutoButtonColor = false,
            BackgroundTransparency = 1, Parent = scrollingframe, BorderSizePixel = 0, Size = dim2(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, BackgroundColor3 = rgb(255, 255, 255)
        })
    end

    function cfg.refresh_options(options)
        for _, v in ipairs(cfg.option_instances) do v:Destroy() end
        cfg.option_instances = {}
        for _, option in ipairs(options) do
            local btn = cfg.render_option(option)
            insert(cfg.option_instances, btn)
            btn.MouseButton1Click:Connect(function()
                if cfg.current_instance and cfg.current_instance ~= btn then cfg.current_instance.TextColor3 = rgb(170, 170, 170) end
                cfg.current_instance = btn
                btn.TextColor3 = rgb(255, 255, 255)
                flags[cfg.flag] = btn.Text
                cfg.callback(btn.Text)
            end)
        end
    end

    function cfg.filter_options(text)
        for _, v in ipairs(cfg.option_instances) do v.Visible = string.find(v.Text, text) and true or false end
    end

    function cfg.set(value)
        for _, btn in ipairs(cfg.option_instances) do btn.TextColor3 = btn.Text == value and rgb(255, 255, 255) or rgb(170, 170, 170) end
        flags[cfg.flag] = value
        cfg.callback(value)
    end

    cfg.refresh_options(cfg.items)
    config_flags[cfg.flag] = cfg.set
    return setmetatable(cfg, library)
end

function library:slider(options)
    local cfg = {
        name = options.name or nil, suffix = options.suffix or "", flag = options.flag or tostring(2 ^ 789),
        callback = options.callback or function() end, min = options.min or 0, max = options.max or 100,
        intervals = options.interval or 1, default = options.default or 10, value = options.default or 10,
        dragging = false,
    }

    local is_beta = seraphAcc.role == "contributor" or seraphAcc.role == "beta"
    local clr = options.unsafe and rgb(210, 215, 192) or rgb(255, 255, 255)
    if is_beta and options.beta then clr = hex("#e67e22") elseif not is_beta and options.beta then clr = hex("#e67e22"):lerp(rgb(0, 0, 0), .2) end

    local slider = library:create("Frame", { Parent = self.elements, BackgroundTransparency = 1, Size = dim2(1, 0, 0, 25), BorderSizePixel = 0, BackgroundColor3 = rgb(255, 255, 255), Active = false })
    cfg.instance = slider

    function cfg.show_element(bool) slider.Visible = bool end
    function cfg:destroy() slider:Destroy() table.clear(cfg) end

    local label = library:create("TextLabel", {
        FontFace = library.font, TextColor3 = clr, RichText = true, Text = "slider", Parent = slider,
        Size = dim2(1, 0, 0, 0), Position = dim2(0, 1, 0, -2), BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left, BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.XY, TextSize = 12, Active = false,
    })

    local outline = library:create("TextButton", { Parent = slider, Text = "", AutoButtonColor = false, Position = dim2(0, 0, 0, 13), Size = dim2(1, 0, 0, 12), BorderSizePixel = 0, BackgroundColor3 = self.color })
    library:apply_theme(outline, tostring(self.count), "BackgroundColor3")

    local slider_color = (is_beta and options.beta) and hex("#e67e22") or ((not is_beta and options.beta) and hex("#e67e22"):lerp(rgb(0, 0, 0), .2) or themes.preset.button)

    local inline = library:create("Frame", { Parent = outline, Position = dim2(0, 1, 0, 1), Size = dim2(1, -2, 1, -2), BorderSizePixel = 0, BackgroundColor3 = themes.preset.inline, Active = false })
    library:apply_theme(inline, "inline", "BackgroundColor3")
    library:create("UIGradient", { Parent = inline, Rotation = 90, Color = rgbseq(rgb(255, 255, 255), rgb(222, 222, 222)) })

    local accent = library:create("Frame", { Parent = inline, Size = dim2(0.5, 0, 1, 0), BorderSizePixel = 0, BackgroundColor3 = slider_color, Active = false })
    accent:SetAttribute("buttonPrimary", true)
    library:create("UIGradient", { Parent = accent, Rotation = 90, Color = rgbseq(rgb(255, 255, 255), rgb(155, 155, 155)) })

    if themes.corners then
        library:create("UICorner", { Parent = outline, CornerRadius = UDim.new(0, 2) })
        library:create("UICorner", { Parent = inline, CornerRadius = UDim.new(0, 2) })
        library:create("UICorner", { Parent = accent, CornerRadius = UDim.new(0, 2) })
        library:create("UICorner", { Parent = slider, CornerRadius = UDim.new(0, 2) })
    end

    function cfg.set(value)
        local v = tonumber(value)
        if v == nil then return end
        cfg.value = clamp(library:round(v, cfg.intervals), cfg.min, cfg.max)
        accent.Size = dim2((cfg.value - cfg.min) / (cfg.max - cfg.min), 0, 1, 0)
        label.Text = cfg.name .. "<font color='#AAAAAA'> - " .. tostring(cfg.value) .. cfg.suffix .. "</font>"
        flags[cfg.flag] = cfg.value
        cfg.callback(flags[cfg.flag])
    end

    cfg.set(cfg.default)
    outline.MouseButton1Down:Connect(function() cfg.dragging = true end)
    library:connection(uis.InputChanged, function(input)
        if cfg.dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local sx = (input.Position.X - inline.AbsolutePosition.X) / inline.AbsoluteSize.X
            cfg.set(((cfg.max - cfg.min) * sx) + cfg.min)
        end
    end)
    library:connection(uis.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then cfg.dragging = false end
    end)

    config_flags[cfg.flag] = cfg.set
    return setmetatable(cfg, library)
end

function library:dropdown(options)
    local cfg = {
        name = options.name or nil, flag = options.flag or tostring(random(1, 9999999)),
        items = options.items or { "" }, callback = options.callback or function() end,
        multi = options.multi or false, scrolling = true, open = false,
        option_instances = {}, multi_items = {},
    }

    cfg.default = options.default or (cfg.multi and { cfg.items[1] }) or cfg.items[1] or "None"
    flags[cfg.flag] = {}

    local is_beta = seraphAcc.role == "contributor" or seraphAcc.role == "beta"
    local clr = options.unsafe and rgb(210, 215, 192) or rgb(255, 255, 255)
    if is_beta and options.beta then clr = hex("#e67e22") elseif not is_beta and options.beta then clr = hex("#e67e22"):lerp(rgb(0, 0, 0), .2) end

    local dropdown = library:create("Frame", { Parent = self.elements, BackgroundTransparency = 1, Size = dim2(1, 0, 0, 16), BorderSizePixel = 0, BackgroundColor3 = rgb(255, 255, 255), Active = false })
    cfg.instance = dropdown
    function cfg.show_element(bool) dropdown.Visible = bool end
    function cfg:destroy() dropdown:Destroy() table.clear(cfg) end

    local dropdown_holder = library:create("TextButton", { AnchorPoint = vec2(1, 0), AutoButtonColor = false, Text = "", BackgroundColor3 = rgb(), Parent = dropdown, Position = dim2(1, 0, 0, 0), Size = dim2(0.5, 0, 0, 16), BorderSizePixel = 0 })
    library:apply_theme(dropdown_holder, tostring(self.count), "BackgroundColor3")

    local inline = library:create("Frame", { Parent = dropdown_holder, Position = dim2(0, 1, 0, 1), Size = dim2(1, -2, 1, -2), BorderSizePixel = 0, BackgroundColor3 = themes.preset.inline, Active = false })

    local text = library:create("TextLabel", { FontFace = library.font, TextColor3 = clr, Text = cfg.name, Parent = inline, Size = dim2(1, 0, 1, 0), BackgroundTransparency = 1, Position = dim2(0, 0, 0, 1), BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.X, TextSize = 12, Active = false })
    local title = library:create("TextLabel", { FontFace = library.font, TextColor3 = clr, Text = cfg.name, Parent = dropdown, Size = dim2(1, 0, 1, 0), Position = dim2(0, 1, 0, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.X, TextSize = 12, Active = false })
    library:create("UIGradient", { Parent = inline, Rotation = 90, Color = rgbseq(rgb(255, 255, 255), rgb(155, 155, 155)) })

    if themes.corners then
        library:create("UICorner", { Parent = inline, CornerRadius = UDim.new(0, 2) })
        library:create("UICorner", { Parent = dropdown_holder, CornerRadius = UDim.new(0, 2) })
    end

    local accent = library:create("Frame", { Parent = library.gui, Size = dim2(0.0907348021864891, 0, 0.006218905560672283, 20), Position = dim2(0, 500, 0, 100), BorderSizePixel = 0, Visible = false, AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = self.color, ZIndex = 50000, Active = true })
    library:apply_theme(accent, tostring(self.count), "BackgroundColor3")

    local inline_overlay = library:create("Frame", { Parent = accent, Size = dim2(1, -2, 1, -2), Position = dim2(0, 1, 0, 1), BorderSizePixel = 0, BackgroundColor3 = themes.preset.inline, ZIndex = 50005, Active = false })
    library:apply_theme(inline_overlay, "inline", "BackgroundColor3")
    library:create("UIGradient", { Parent = inline_overlay, Rotation = 90, Transparency = numseq({ numkey(0, 1), numkey(0.7, 1), numkey(1, 0.5) }), Color = rgbseq(rgb(255, 255, 255), rgb(155, 155, 155)) })

    local maxInlineSize = 200
    local inner = library:create(cfg.scrolling and "ScrollingFrame" or "Frame", { Parent = accent, Size = dim2(1, -2, 1, -2), Position = dim2(0, 1, 0, 1), BorderSizePixel = 0, AutomaticSize = cfg.scrolling and Enum.AutomaticSize.None or Enum.AutomaticSize.Y, BackgroundColor3 = themes.preset.inline, ZIndex = 50000, Active = false })
    library:apply_theme(inner, "inline", "BackgroundColor3")
    library:create("UIGradient", { Parent = inner, Rotation = 90, Color = rgbseq(rgb(255, 255, 255), rgb(155, 155, 155)) })
    library:create("UIListLayout", { Parent = inner, Padding = dim(0, 6), SortOrder = Enum.SortOrder.LayoutOrder })
    library:create("UIPadding", { PaddingTop = dim(0, 5), PaddingBottom = dim(0, 2), Parent = inner, PaddingRight = dim(0, 6), PaddingLeft = dim(0, 6) })
    library:create("UIPadding", { PaddingBottom = dim(0, 2), Parent = accent })

    function cfg.render_option(text)
        local btn = library:create("TextButton", { FontFace = library.font, AutoButtonColor = false, TextColor3 = clr, Text = string.lower(text), Parent = inner, Size = dim2(1, 0, 0, 0), Position = dim2(0, 0, 0, 1), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, BackgroundColor3 = rgb(), BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.Y, TextSize = 12 })
        btn.Name = text
        return btn
    end

    function cfg.set_visible(bool)
        accent.Visible = bool
        local cs, lh = 0, 0
        for _, t in ipairs(cfg.option_instances) do cs += t.AbsoluteSize.Y + 6 lh = t.AbsoluteSize.Y end
        inner.Size = UDim2.new(1, -2, 0, clamp(cs, 0, maxInlineSize) + lh)
        if inner:IsA("ScrollingFrame") then inner.CanvasSize = UDim2.new(0, 0, 0, cs + lh) inner.ScrollBarThickness = 1 end
        inline_overlay.Size = inner.Size
        if bool then
            accent.Size = dim2(0, dropdown_holder.AbsoluteSize.X, 0, accent.Size.Y.Offset)
            position_overlay(accent, dropdown_holder, 0)
        end
    end

    function cfg.set(value)
        local selected, isTable = {}, type(value) == "table"
        if value == nil then return end
        for _, option in ipairs(cfg.option_instances) do
            if option.Name == value or (isTable and find(value, option.Name)) then
                insert(selected, option.Name) cfg.multi_items = selected option.TextColor3 = clr
            else
                option.TextColor3 = clr:Lerp(rgb(), .23)
            end
        end
        inline_overlay.Size = inner.Size
        text.Text = string.lower(isTable and concat(selected, ", ") or selected[1])
        text.TextTruncate = Enum.TextTruncate.AtEnd
        flags[cfg.flag] = isTable and selected or selected[1]
        cfg.callback(flags[cfg.flag])
    end

    function cfg.refresh_options(list)
        for _, option in ipairs(cfg.option_instances) do option:Destroy() end
        cfg.option_instances = {}
        for _, option in ipairs(list) do
            local btn = cfg.render_option(option)
            insert(cfg.option_instances, btn)
            btn.MouseButton1Down:Connect(function()
                if cfg.multi then
                    local idx = find(cfg.multi_items, btn.Name)
                    if idx then remove(cfg.multi_items, idx) else insert(cfg.multi_items, btn.Name) end
                    cfg.set(cfg.multi_items)
                else
                    cfg.set_visible(false) cfg.open = false cfg.set(btn.Name)
                end
            end)
        end
    end

    cfg.refresh_options(cfg.items)
    cfg.set(cfg.default)
    config_flags[cfg.flag] = cfg.set

    dropdown_holder.MouseButton1Click:Connect(function()
        cfg.open = not cfg.open
        cfg.set_visible(cfg.open)
    end)

    local inputEndedSig = nil
    local function inputEndedFunc(input)
        if cfg.open and input.UserInputType == Enum.UserInputType.MouseButton1 and not (library:mouse_in_frame(accent) or library:mouse_in_frame(dropdown)) then
            cfg.open = false cfg.set_visible(false)
        end
    end
    local function attachInputEnded()
        if inputEndedSig then inputEndedSig:Disconnect() end
        inputEndedSig = uis.InputEnded:Connect(inputEndedFunc)
    end
    local function detachInputEnded()
        if inputEndedSig then inputEndedSig:Disconnect() inputEndedSig = nil end
    end

    attachInputEnded()

    library.guiVisibilityChanged:Connect(function()
        cfg.set_visible(false)
        if library.gui_visible then attachInputEnded() else detachInputEnded() end
    end)

    return setmetatable(cfg, library)
end

function library:colorpicker(options)
    local cfg = {
        name = options.name or "Color", flag = options.flag or tostring(2 ^ 789),
        color = options.color or Color3.new(1, 1, 1), alpha = options.alpha and 1 - options.alpha or 0,
        open = false, callback = options.callback or function() end,
    }

    local cp_element = library:create("TextButton", { Parent = self.elements, BackgroundTransparency = 1, Text = "", AutoButtonColor = false, Size = dim2(1, 0, 0, 12), BorderSizePixel = 0, BackgroundColor3 = rgb(255, 255, 255) })
    cfg.instance = cp_element
    function cfg:destroy() cp_element:Destroy() table.clear(cfg) end

    local accent = library:create("Frame", { AnchorPoint = vec2(1, 0), Parent = cp_element, Position = dim2(1, 0, 0, 0), Size = dim2(0, 30, 0, 12), BorderSizePixel = 0, BackgroundColor3 = self.color, Active = false })
    library:apply_theme(accent, tostring(self.count), "BackgroundColor3")

    local cp_color = library:create("Frame", { Parent = accent, Position = dim2(0, 1, 0, 1), Size = dim2(1, -2, 1, -2), BorderSizePixel = 0, BackgroundColor3 = rgb(255, 255, 255), Active = false })
    library:create("UIGradient", { Parent = cp_color, Rotation = 90, Color = rgbseq(rgb(255, 255, 255), rgb(155, 155, 155)) })

    if themes.corners then
        library:create("UICorner", { Parent = cp_color, CornerRadius = UDim.new(0, 2) })
        library:create("UICorner", { Parent = accent, CornerRadius = UDim.new(0, 2) })
    end

    library:create("TextLabel", { FontFace = library.font, Text = cfg.name, Parent = cp_element, Size = dim2(1, 0, 1, 0), Position = dim2(0, 1, 0, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.X, TextSize = 12, Active = false })

    local picker = library:create("Frame", { Parent = library.gui, ZIndex = 50000, Position = dim2(0.6888179183006287, 0, 0.24751244485378265, 0), Visible = false, Size = dim2(0, 150, 0, 150), BorderSizePixel = 0, BackgroundColor3 = self.color, Active = true })
    library:apply_theme(picker, tostring(self.count), "BackgroundColor3")
    library:create("UICorner", { Parent = picker, CornerRadius = UDim.new(0, 2) })

    local a = library:create("Frame", { Parent = picker, Size = dim2(1, 0, 1, 0), BorderSizePixel = 0, BackgroundColor3 = self.color, Active = false })
    library:apply_theme(a, tostring(self.count), "BackgroundColor3")

    local e = library:create("Frame", { Parent = a, Position = dim2(0, 1, 0, 1), Size = dim2(1, -2, 1, -2), BorderSizePixel = 0, BackgroundColor3 = rgb(0, 0, 0), BackgroundTransparency = 0.6, ZIndex = -1, Active = false })
    library:create("UIPadding", { PaddingTop = dim(0, 7), PaddingBottom = dim(0, -13), Parent = e, PaddingRight = dim(0, 6), PaddingLeft = dim(0, 7) })

    local tb_holder = library:create("Frame", { Parent = e, Position = dim2(0, 0, 1, -36), Size = dim2(1, -1, 0, 16), BorderSizePixel = 0, BackgroundColor3 = self.color, Active = false })
    library:apply_theme(tb_holder, tostring(self.count), "BackgroundColor3")

    local textbox = library:create("TextBox", { FontFace = library.font, Text = "", Parent = tb_holder, BackgroundTransparency = 0, ClearTextOnFocus = false, PlaceholderColor3 = rgb(255, 255, 255), Size = dim2(1, -2, 1, -2), Position = dim2(0, 1, 0, 1), BorderSizePixel = 0, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Center, BackgroundColor3 = themes.preset.inline, Active = false })
    library:apply_theme(textbox, "inline", "BackgroundColor3")

    local hue_btn = library:create("TextButton", { AnchorPoint = vec2(1, 0), Parent = e, Position = dim2(1, -1, 0, 0), Size = dim2(0, 14, 1, -60), Text = "", AutoButtonColor = false, BorderSizePixel = 0, BackgroundColor3 = themes.preset.inline })
    library:apply_theme(hue_btn, "inline", "BackgroundColor3")

    local hue_drag = library:create("Frame", { Parent = hue_btn, Position = dim2(0, 1, 0, 1), Size = dim2(1, -2, 1, -2), BorderSizePixel = 0, BackgroundColor3 = rgb(255, 255, 255), Active = false })
    library:create("UIGradient", { Rotation = -90, Parent = hue_drag, Color = rgbseq{ rgbkey(0, rgb(255, 0, 0)), rgbkey(0.17, rgb(255, 255, 0)), rgbkey(0.33, rgb(0, 255, 0)), rgbkey(0.5, rgb(0, 255, 255)), rgbkey(0.67, rgb(0, 0, 255)), rgbkey(0.83, rgb(255, 0, 255)), rgbkey(1, rgb(255, 0, 0)) } })
    local hue_picker = library:create("Frame", { Parent = hue_drag, BorderMode = Enum.BorderMode.Inset, Size = dim2(1, 2, 0, 3), Position = dim2(0, -1, 0, -1), BackgroundColor3 = rgb(255, 255, 255), Active = false })

    local alpha_btn = library:create("TextButton", { AnchorPoint = vec2(0, 0.5), Parent = e, Position = dim2(0, 0, 1, -48), Size = dim2(1, -1, 0, 14), Text = "", AutoButtonColor = false, BorderSizePixel = 0, BackgroundColor3 = themes.preset.inline })
    library:apply_theme(alpha_btn, "inline", "BackgroundColor3")

    local alpha_color = library:create("Frame", { Parent = alpha_btn, Position = dim2(0, 1, 0, 1), Size = dim2(1, -2, 1, -2), BorderSizePixel = 0, BackgroundColor3 = rgb(0, 221, 255), Active = false })
    local alphaind = library:create("ImageLabel", { ScaleType = Enum.ScaleType.Tile, Parent = alpha_color, Image = "rbxassetid://18274452449", BackgroundTransparency = 1, Size = dim2(1, 0, 1, 0), TileSize = dim2(0, 4, 0, 4), BorderSizePixel = 0, BackgroundColor3 = rgb(255, 255, 255), Active = false })
    library:create("UIGradient", { Parent = alphaind, Rotation = 180, Transparency = numseq{ numkey(0, 0), numkey(1, 1) } })
    local alpha_picker = library:create("Frame", { Parent = alpha_color, BorderMode = Enum.BorderMode.Inset, Size = dim2(0, 3, 1, 2), Position = dim2(0, -1, 0, -1), BackgroundColor3 = rgb(255, 255, 255), Active = false })

    local sv_btn = library:create("TextButton", { Parent = e, Size = dim2(1, -20, 1, -60), Text = "", AutoButtonColor = false, BorderSizePixel = 0, BackgroundColor3 = themes.preset.inline })
    library:apply_theme(sv_btn, "inline", "BackgroundColor3")

    local sv_color = library:create("Frame", { Parent = sv_btn, Position = dim2(0, 1, 0, 1), Size = dim2(1, -2, 1, -2), BorderSizePixel = 0, BackgroundColor3 = rgb(0, 221, 255), Active = false })
    local val_btn = library:create("TextButton", { Parent = sv_color, Text = "", AutoButtonColor = false, Size = dim2(1, 0, 1, 0), BorderSizePixel = 0, BackgroundColor3 = rgb(255, 255, 255) })
    library:create("UIGradient", { Parent = val_btn, Transparency = numseq{ numkey(0, 0), numkey(1, 1) } })

    local sv_picker = library:create("Frame", { Parent = sv_color, Size = dim2(0, 3, 0, 3), BorderSizePixel = 0, BackgroundColor3 = rgb(0, 0, 0), Active = false })
    library:create("Frame", { Parent = sv_picker, Position = dim2(0, 1, 0, 1), Size = dim2(1, -2, 1, -2), BorderSizePixel = 0, BackgroundColor3 = rgb(255, 255, 255), Active = false })

    local sat_btn = library:create("TextButton", { Parent = sv_color, Text = "", AutoButtonColor = false, Size = dim2(1, 0, 1, 0), ZIndex = 2, BorderSizePixel = 0, BackgroundColor3 = rgb(255, 255, 255) })
    library:create("UIGradient", { Rotation = 270, Parent = sat_btn, Transparency = numseq{ numkey(0, 0), numkey(1, 1) }, Color = rgbseq{ rgbkey(0, rgb(0, 0, 0)), rgbkey(1, rgb(0, 0, 0)) } })

    local dragging_sat, dragging_hue, dragging_alpha = false, false, false
    local h, s, v = cfg.color:ToHSV()
    local a_val = cfg.alpha
    flags[cfg.flag] = {}

    function cfg.set_visible(bool)
        picker.Visible = bool
        picker.Position = dim_offset(cp_color.AbsolutePosition.X - 1, cp_color.AbsolutePosition.Y + cp_color.AbsoluteSize.Y + 65)
    end
    function cfg.show_element(bool) cp_element.Visible = bool end

    function cfg.set(color, alpha)
        if color then h, s, v = color:ToHSV() end
        if alpha then a_val = alpha end
        local Color = Color3.fromHSV(h, s, v)
        hue_picker.Position = dim2(0, -1, 1 - h, -1)
        alpha_picker.Position = dim2(1 - a_val, -1, 0, -1)
        sv_picker.Position = dim2(s, -1, 1 - v, -1)
        alpha_color.BackgroundColor3 = Color
        cp_color.BackgroundColor3 = Color
        sv_color.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        flags[cfg.flag] = { Color = Color, Transparency = a_val }
        textbox.Text = string.format("%s, %s, %s, ", library:round(Color.R * 255), library:round(Color.G * 255), library:round(Color.B * 255))
        textbox.Text ..= library:round(1 - a_val, 0.01)
        cfg.callback(Color, a_val)
    end

    function cfg.update_color()
        local m = uis:GetMouseLocation()
        local offset = vec2(m.X, m.Y - gui_offset)
        if dragging_sat then
            s = clamp((offset - sv_btn.AbsolutePosition).X / sv_btn.AbsoluteSize.X, 0, 1)
            v = 1 - clamp((offset - sv_btn.AbsolutePosition).Y / sv_btn.AbsoluteSize.Y, 0, 1)
        elseif dragging_hue then
            h = 1 - clamp((offset - hue_btn.AbsolutePosition).Y / hue_btn.AbsoluteSize.Y, 0, 1)
        elseif dragging_alpha then
            a_val = 1 - clamp((offset - alpha_btn.AbsolutePosition).X / alpha_btn.AbsoluteSize.X, 0, 1)
        end
        cfg.set(nil, nil)
    end

    cfg.set(cfg.color, cfg.alpha)
    config_flags[cfg.flag] = cfg.set

    cp_element.MouseButton1Click:Connect(function() cfg.open = not cfg.open cfg.set_visible(cfg.open) end)
    library:connection(uis.InputChanged, function(input)
        if (dragging_sat or dragging_hue or dragging_alpha) and input.UserInputType == Enum.UserInputType.MouseMovement then cfg.update_color() end
    end)

    library:connection(uis.InputEnded, function(input)
        if not cfg.open then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging_sat, dragging_hue, dragging_alpha = false, false, false
            if not (library:mouse_in_frame(cp_element) or library:mouse_in_frame(picker)) then cfg.open = false cfg.set_visible(false) end
        end
    end)

    alpha_btn.MouseButton1Down:Connect(function() dragging_alpha = true end)
    hue_btn.MouseButton1Down:Connect(function() dragging_hue = true end)
    sat_btn.MouseButton1Down:Connect(function() dragging_sat = true end)

    textbox.FocusLost:Connect(function()
        local ok, hexcolor = pcall(hex, textbox.Text)
        if ok and hexcolor then
            cfg.set(rgb(floor(hexcolor.R * 255), floor(hexcolor.G * 255), floor(hexcolor.B * 255)), cfg.alpha)
            return
        end
        local r, g, b, av = library:convert(textbox.Text)
        if not av then av = 1 end
        if r and g and b and av then cfg.set(rgb(r, g, b), 1 - av) end
    end)

    library.guiVisibilityChanged:Connect(function() cfg.set_visible(false) end)
    return setmetatable(cfg, library)
end

function library:textbox(options)
    local cfg = {
        name = options.name or "...", placeholder = options.placeholder or options.placeholdertext or options.holder or options.holdertext or "type here...",
        default = options.default, flag = options.flag or "textbox_flag", callback = options.callback or function() end, visible = options.visible or true,
    }

    local frame = library:create("TextButton", { AnchorPoint = vec2(1, 0), Text = "", AutoButtonColor = false, Parent = self.elements, Position = dim2(1, 0, 0, 0), Size = dim2(1, 0, 0, 16), BorderSizePixel = 0, BackgroundColor3 = self.color })
    local frame_inline = library:create("Frame", { Parent = frame, Position = dim2(0, 1, 0, 1), Size = dim2(1, -2, 1, -2), BorderSizePixel = 0, BackgroundColor3 = themes.preset.inline, Active = false })
    local input = library:create("TextBox", { Parent = frame, FontFace = library.font, TextTruncate = Enum.TextTruncate.AtEnd, TextSize = 12, Size = dim2(1, -6, 1, 0), RichText = true, CursorPosition = -1, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Position = dim2(0, 6, 0, 0), BorderSizePixel = 0, PlaceholderColor3 = rgb(170, 170, 170), Active = false })

    function cfg:destroy() frame:Destroy() table.clear(cfg) end
    function cfg.set(text) flags[cfg.flag] = text input.Text = text cfg.callback(text) end
    function cfg.show_element(bool) frame.Visible = bool end

    config_flags[cfg.flag] = cfg.set
    if cfg.default then cfg.set(cfg.default) end

    input:GetPropertyChangedSignal("Text"):Connect(function() cfg.set(input.Text) end)
    return setmetatable(cfg, library)
end

function library:keybind(options)
    local cfg = {
        flag = options.flag or "keybind_flag", callback = options.callback or function() end,
        open = false, binding = nil, name = options.name or nil, ignore_key = options.ignore or false,
        key = options.key or nil, display = options.display or nil, mode = options.mode or "hold",
        active = options.default or false, hold_instances = {},
    }

    insert(keybinds, cfg)
    flags[cfg.flag] = {}

    local keybind = library:create("Frame", { Parent = self.elements, BackgroundTransparency = 1, Size = dim2(1, 0, 0, 16), BorderSizePixel = 0, BackgroundColor3 = rgb(255, 255, 255), Active = false })
    cfg.instance = keybind
    function cfg:destroy() keybind:Destroy() table.clear(cfg) end
    function cfg.show_element(bool) keybind.Visible = bool end

    local keybind_holder = library:create("TextButton", { AnchorPoint = vec2(1, 0), AutoButtonColor = false, Text = "", Parent = keybind, BackgroundTransparency = 1, Position = dim2(1, 0, 0, 0), Size = dim2(0.5, 0, 0, 16), BorderSizePixel = 0, BackgroundColor3 = self.color })
    local inline = library:create("Frame", { Parent = keybind_holder, Position = dim2(0, 1, 0, 1), BackgroundTransparency = 1, Size = dim2(1, -2, 1, -2), BorderSizePixel = 0, BackgroundColor3 = themes.preset.inline, Active = false })
    library:create("UIGradient", { Parent = inline, Rotation = 90, Color = rgbseq(rgb(255, 255, 255), rgb(155, 155, 155)) })

    local text = library:create("TextLabel", { FontFace = library.font, Text = cfg.name, Parent = inline, Size = dim2(1, 0, 1, 0), BackgroundTransparency = 1, Position = dim2(0, 0, 0, -1), TextColor3 = rgb(221, 221, 221), BorderSizePixel = 0, TextXAlignment = Enum.TextXAlignment.Right, AutomaticSize = Enum.AutomaticSize.X, TextSize = 10, Active = false })
    local title = library:create("TextLabel", { FontFace = library.font, Text = cfg.name, Parent = keybind, Size = dim2(0, 0, 1, 0), Position = dim2(0, 1, 0, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.X, TextColor3 = options.unsafe and rgb(210, 215, 192) or rgb(255, 255, 255), TextSize = 12, Active = false })

    if options.tip then
        local question = library:create("TextLabel", { FontFace = library.font, Text = '?', Parent = title, Size = dim2(0, 0, 1, 0), Position = dim2(1, 3, 0, -3), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.X, TextSize = 8, Active = false })
        question.MouseEnter:Connect(function() show_tooltip(true, options.tip, question.AbsolutePosition - vec2(0, 30)) end)
        question.MouseLeave:Connect(function() show_tooltip(false, options.tip, question.AbsolutePosition - vec2(0, 30)) end)
    end

    local accent = library:create("Frame", { Parent = library.gui, Visible = false, Size = dim2(0.0907348021864891, 0, 0.006218905560672283, 20), Position = dim2(0, 500, 0, 100), BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = self.color, ZIndex = 50000, Active = true })
    library:apply_theme(accent, tostring(self.count), "BackgroundColor3")

    local inner = library:create("Frame", { Parent = accent, Size = dim2(1, -2, 1, -2), Position = dim2(0, 1, 0, 1), BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = themes.preset.inline, ZIndex = 50000, Active = false })
    library:apply_theme(inner, "inline", "BackgroundColor3")
    library:create("UIListLayout", { Parent = inner, Padding = dim(0, 6), SortOrder = Enum.SortOrder.LayoutOrder })
    library:create("UIPadding", { PaddingTop = dim(0, 5), PaddingBottom = dim(0, 2), Parent = inner, PaddingRight = dim(0, 6), PaddingLeft = dim(0, 6) })
    library:create("UIPadding", { PaddingBottom = dim(0, 2), Parent = accent })

    for _, v in ipairs({ "Hold", "Toggle", "Always" }) do
        local option = library:create("TextButton", { FontFace = library.font, Text = v, Parent = inner, Position = dim2(0, 0, 0, 1), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.XY, TextSize = 12, TextColor3 = rgb(170, 170, 170), AutoButtonColor = false })
        cfg.hold_instances[v] = option
        option.MouseButton1Click:Connect(function() cfg.set(v) cfg.set_visible(false) cfg.open = false end)
    end

    function cfg.modify_mode_color(path)
        for _, v in pairs(cfg.hold_instances) do v.TextColor3 = rgb(170, 170, 170) end
        if cfg.hold_instances[path] then cfg.hold_instances[path].TextColor3 = rgb(255, 255, 255) end
    end

    function cfg.set_mode(mode)
        cfg.mode = mode
        if mode == "Always" then cfg.set(true) elseif mode == "Hold" then cfg.set(false) end
        flags[cfg.flag]["mode"] = mode
        cfg.modify_mode_color(mode)
    end

    function cfg.set(input)
        if type(input) == "boolean" then
            local cached = input
            if cfg.mode == "Always" then cached = true end
            cfg.active = cached
            cfg.callback(cached)
        elseif tostring(input):find("Enum") then
            cfg.key = input.Name == "Escape" and "..." or input
            cfg.callback(cfg.active or false)
        elseif find({ "Toggle", "Hold", "Always" }, input) then
            cfg.set_mode(input)
            if input == "Always" then cfg.active = true end
            cfg.callback(cfg.active or false)
        elseif type(input) == "table" then
            input.key = type(input.key) == "string" and input.key ~= "..." and library:convert_enum(input.key) or input.key
            input.key = input.key == Enum.KeyCode.Escape and "..." or input.key
            cfg.key = input.key or "..."
            cfg.mode = input.mode or "Toggle"
            cfg.set_mode(input.mode)
            if input.active then cfg.active = input.active end
        end
        flags[cfg.flag] = { mode = cfg.mode, key = cfg.key, active = cfg.active }
        local t = tostring(cfg.key) ~= "Enums" and (keys[cfg.key] or tostring(cfg.key):gsub("Enum.", "")) or nil
        local tt = t and (tostring(t):gsub("KeyCode.", ""):gsub("UserInputType.", ""))
        text.Text = "[" .. tt .. "]"
    end

    function cfg.set_visible(bool)
        accent.Visible = bool
        accent.Size = dim2(0, keybind_holder.AbsoluteSize.X, 0, accent.Size.Y.Offset)
        if bool then position_overlay(accent, keybind_holder, 0) end
    end

    keybind_holder.MouseButton1Down:Connect(function()
        task.wait()
        text.Text = "[-]"
        if cfg.binding then cfg.binding:Disconnect() end
        cfg.binding = library:connection(uis.InputBegan, function(input)
            cfg.set((input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode or input.UserInputType))
            if cfg.binding then cfg.binding:Disconnect() cfg.binding = nil end
        end)
    end)

    keybind_holder.MouseButton2Down:Connect(function() cfg.open = not cfg.open cfg.set_visible(cfg.open) end)

    library:connection(uis.InputBegan, function(input, gpe)
        if not gpe then
            if input.KeyCode == cfg.key or input.UserInputType == cfg.key then
                if cfg.mode == "Toggle" then cfg.active = not cfg.active cfg.set(cfg.active)
                elseif cfg.mode == "Hold" then cfg.set(true) end
            end
        end
    end)

    library:connection(uis.InputEnded, function(input, gpe)
        if gpe then return end
        if input.KeyCode == cfg.key or input.UserInputType == cfg.key then
            if cfg.mode == "Hold" then cfg.set(false) end
        end
        if library.gui_visible and input.UserInputType == Enum.UserInputType.MouseButton1 then
            if not (library:mouse_in_frame(keybind_holder) or library:mouse_in_frame(accent)) then cfg.open = false cfg.set_visible(false) end
        end
    end)

    config_flags[cfg.flag] = cfg.set
    cfg.set({ mode = cfg.mode, active = cfg.active, key = cfg.key })
    cfg.set_mode(cfg.mode)

    library.guiVisibilityChanged:Connect(function() cfg.set_visible(false) end)
    return setmetatable(cfg, library)
end

function library:button(options)
    local cfg = { name = options.name or "button", callback = options.callback or function() end }

    local frame = library:create("TextButton", { AnchorPoint = vec2(1, 0), Text = "", AutoButtonColor = false, Parent = self.elements, Position = dim2(1, 0, 0, 0), Size = dim2(1, 0, 0, 16), BorderSizePixel = 0, BackgroundColor3 = self.color })
    library:apply_theme(frame, tostring(self.count), "BackgroundColor3")

    local frame_inline = library:create("Frame", { Parent = frame, Position = dim2(0, 1, 0, 1), Size = dim2(1, -2, 1, -2), BorderSizePixel = 0, BackgroundColor3 = themes.preset.inline, Active = false })
    library:apply_theme(frame_inline, "inline", "BackgroundColor3")
    library:create("UIGradient", { Parent = frame_inline, Rotation = 90, Color = rgbseq(rgb(255, 255, 255), rgb(188, 188, 188)) })

    if themes.corners then
        library:create("UICorner", { Parent = frame_inline, CornerRadius = UDim.new(0, 2) })
        library:create("UICorner", { Parent = frame, CornerRadius = UDim.new(0, 2) })
    end

    local label = library:create("TextLabel", { FontFace = library.font, Text = cfg.name, Parent = frame, Size = dim2(1, 0, 1, 0), BackgroundTransparency = 1, Position = dim2(0, 1, 0, 1), BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.X, TextSize = 12, Active = false })

    frame.MouseEnter:Connect(function()
        library:create_tween(frame_inline, {0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out}, { BackgroundColor3 = themes.preset.inline:Lerp(rgb(255, 255, 255), 0.05) })
    end)
    frame.MouseLeave:Connect(function()
        library:create_tween(frame_inline, {0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out}, { BackgroundColor3 = themes.preset.inline })
    end)

    frame.MouseButton1Click:Connect(function() cfg.callback() end)
    function cfg:destroy() frame:Destroy() table.clear(cfg) end
    function cfg.show_element(bool) frame.Visible = bool end
    function cfg.set_text(t) label.Text = t end
    return setmetatable(cfg, library)
end

return library
