local SCRIPT_NAME = "Organized Output Directory"
local VERSION_STRING = "1.0.3"

-- todo
--[[
add back the ascii checkmark for the game folder
]]

-- requirements
local OPERATING_SYSTEM_REQUIREMENTS = { "Windows 10/11" }
local OBS_VERSION_REQUIREMENT = "29.0.0"

-- URLs
local GITHUB_PROJECT_URL = "https://github.com/MrMartin92/obs_organized_output_directory"
local GITHUB_PROJECT_LICENCE_URL =
"https://raw.githubusercontent.com/MrMartin92/obs_organized_output_directory/main/LICENSE"
local GITHUB_PROJECT_BUG_TRACKER_URL = GITHUB_PROJECT_URL .. "/issues"
local GITHUB_AUTHOR_URL = "https://github.com/MrMartin92"
local TWITCH_AUTHOR_URL = "https://twitch.tv/MrMartin_"
local KOFI_URL = "https://ko-fi.com/MrMartin_"

-- wildcards
local WILDCARD_WINDOW_TITLE = "%%w"
local WILDCARD_WINDOW_TITLE_ASCII = "%%wa"
local WIDLCARD_EXECUTABLE = "%%e"
local WIDLCARD_EXECUTABLE_ASCII = "%%ea"
local WILDCARD_ORIGINAL_FILE_NAME = "%%o"

-- WildCard replacements
local replacements = {
    [WILDCARD_WINDOW_TITLE]       = "window_title",
    [WILDCARD_WINDOW_TITLE_ASCII] = "window_title_ascii",
    [WIDLCARD_EXECUTABLE]         = "executable_title",
    [WIDLCARD_EXECUTABLE_ASCII]   = "executable_title_ascii",
    [WILDCARD_ORIGINAL_FILE_NAME] = "original_name"
}

-- enum variables
local ENUM_WINDOW_TITLE = "Window Title"
local ENUM_PROCESS_NAME = "Process Name"


-- Which setting to set folder name from
local name_source_enum = {
    [ENUM_WINDOW_TITLE] = 0,
    [ENUM_PROCESS_NAME] = 1,
}

-- Default values for the script
local DEFAULT_SCREENSHOT_SUB_DIR = "screenshots"
local DEFAULT_REPLAY_SUB_DIR = "replays"
local DEFAULT_RECORDING_SUB_DIR = "recordings"
local DEFAULT_MOVE_RECORDINGS = true
local DEFAULT_ASCII_FILTER = true
local DEFAULT_APPEND_GAME_NAME = true
local DEFAULT_NAME_SOURCE = name_source_enum["Window Title"]
local DEFAULT_FILE_NAME_WILDCARD = WILDCARD_ORIGINAL_FILE_NAME
local DEFAULT_FOLDER_NAME_WILDCARD = WILDCARD_WINDOW_TITLE_ASCII

-- GUI settings
local SCREENSHOT_SUB_DIR = "SCREENSHOT_SUB_DIR"
local REPLAY_SUB_DIR = "REPLAY_SUB_DIR"
local RECORDING_SUB_DIR = "RECORDING_SUB_DIR"
local BOOL_MOVE_RECORDING = "MOVE_RECORDINGS"
local BOOL_ASCII_ONLY = "ASCII_ONLY"
local BOOL_APPEND_GAME_NAME = "APPEND_NAME"
local NAME_SOURCE = "NAME_SOURCE"
local OUTPUT_RENAME_WILDCARD = "WILD_CARDS"


-- cfg short for config short for congifuration
-- strings
local cfg_screenshot_sub_dir
local cfg_replay_sub_dir
local cfg_recording_sub_dir
local cfg_name_source
local cfg_output_wildcards
-- bools
local cfg_move_recordings
local cfg_ascii_filter
local cfg_append_name

-- grab OBS's lua script global object
local obs = obslua

function script_description()
    -- Script description

    -- Grabs the list of operating systems and turns them into one string
    local operating_systems_string = table.concat(OPERATING_SYSTEM_REQUIREMENTS, ", ")

    -- Final script description
    return "<h1>" .. SCRIPT_NAME .. "</h1><p>\n" ..
        "With \"" .. SCRIPT_NAME .. "\" you can create order in your output directory. \n" ..
        "The script automatically creates subdirectories for each game in the output directory. \n" ..
        "To do this, it searches for Window Capture or Game Capture sources in the current scene. \n" ..
        "The last active and hooked source is then used to determine the name of the subdirectory from the window title or the process name.<p>\n" ..
        "You found a bug or you have a feature request? Great! <a href=\"" ..
        GITHUB_PROJECT_BUG_TRACKER_URL .. "\">Open an issue on GitHub.</a><p>\n" ..
        "♥️ If you wish, you can support me on <a href=\"" .. KOFI_URL .. "\">Ko-fi</a>. Thank you! 🤗<p>\n" ..
        "<b>🚀 Version:</b> " .. VERSION_STRING .. "<br>\n" ..
        "<b>🧑‍💻 Author:</b> Tobias Lorenz <a href=\"" ..
        GITHUB_AUTHOR_URL .. "\">[GitHub]</a> <a href=\"" .. TWITCH_AUTHOR_URL .. "\">[Twitch]</a><br>\n" ..
        "<b>🔬 Source:</b> <a href=\"" .. GITHUB_PROJECT_URL .. "\">GitHub.com</a><br>\n" ..
        "<b>🧾 Licence:</b> <a href=\"" .. GITHUB_PROJECT_LICENCE_URL .. "\">MIT</a><br>\n" ..
        "<b>📋 Requirements:</b>" ..
        "<blockquote>" ..
        "Operating Systems: " .. operating_systems_string .. "<br>" ..
        "OBS Version: " .. OBS_VERSION_REQUIREMENT .. "<br>" ..
        "</blockquote><br>" ..
        "<b>🃏 Wildcards:</b>" ..
        "<blockquote>" ..
        WILDCARD_WINDOW_TITLE .. "Window Title" ..
        WILDCARD_WINDOW_TITLE_ASCII .. "Window Title ASCII only" ..
        WIDLCARD_EXECUTABLE .. "Executable Title" ..
        WIDLCARD_EXECUTABLE_ASCII .. "Executable Title ASCII only" ..
        WILDCARD_ORIGINAL_FILE_NAME .. "Original Output File Name" ..
        "</blockquote>"
end

function script_properties()
    -- sets up the settings menu for OBS
    local props = obs.obs_properties_create()

    obs.obs_properties_add_text(props, SCREENSHOT_SUB_DIR, "Screenshot directory name", obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(props, REPLAY_SUB_DIR, "Replay directory name", obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_bool(props, BOOL_MOVE_RECORDING, "Organize recordings")
    obs.obs_properties_add_text(props, RECORDING_SUB_DIR, "Recording directory name", obs.OBS_TEXT_DEFAULT)

    local props_name_source = obs.obs_properties_add_list(
        props,
        NAME_SOURCE,
        "Name source",
        obs.OBS_COMBO_TYPE_LIST,
        obs.OBS_COMBO_FORMAT_INT
    )

    for name, value in pairs(name_source_enum) do
        obs.obs_property_list_add_int(props_name_source, name, value)
    end
    obs.obs_properties_add_bool(props, BOOL_ASCII_ONLY, "Allow only Ascii characters")
    obs.obs_properties_add_bool(props, BOOL_APPEND_GAME_NAME, "Insert Game Name into output")

    return props
end

function script_update(settings)
    print("script_update()")
    -- Updates settings when variables are changed in OBS

    -- update string values
    cfg_screenshot_sub_dir = obs.obs_data_get_string(settings, SCREENSHOT_SUB_DIR)
    cfg_replay_sub_dir = obs.obs_data_get_string(settings, REPLAY_SUB_DIR)
    cfg_recording_sub_dir = obs.obs_data_get_string(settings, RECORDING_SUB_DIR)
    cfg_output_wildcards = obs.obs_data_get_string(settings, RECORDING_SUB_DIR)

    -- update bool values
    cfg_move_recordings = obs.obs_data_get_bool(settings, BOOL_MOVE_RECORDING)
    cfg_ascii_filter = obs.obs_data_get_bool(settings, BOOL_ASCII_ONLY)
    cfg_append_name = obs.obs_data_get_bool(settings, BOOL_APPEND_GAME_NAME)

    -- update integer values
    cfg_name_source = obs.obs_data_get_int(settings, NAME_SOURCE)
end

function script_defaults(settings)
    print("script_defaults()")
    -- Sets default settings for the script in OBS

    -- strings
    obs.obs_data_set_default_string(settings, SCREENSHOT_SUB_DIR, DEFAULT_SCREENSHOT_SUB_DIR)
    obs.obs_data_set_default_string(settings, REPLAY_SUB_DIR, DEFAULT_REPLAY_SUB_DIR)
    obs.obs_data_set_default_string(settings, RECORDING_SUB_DIR, DEFAULT_RECORDING_SUB_DIR)
    obs.obs_data_set_default_string(settings, OUTPUT_RENAME_WILDCARD, DEFAULT_FILE_NAME_WILDCARD)

    -- bools
    obs.obs_data_set_default_bool(settings, BOOL_MOVE_RECORDING, DEFAULT_MOVE_RECORDINGS)
    obs.obs_data_set_default_bool(settings, BOOL_ASCII_ONLY, DEFAULT_ASCII_FILTER)
    obs.obs_data_set_default_bool(settings, BOOL_APPEND_GAME_NAME, DEFAULT_APPEND_GAME_NAME)

    -- lists
    obs.obs_data_set_default_int(settings, NAME_SOURCE, DEFAULT_NAME_SOURCE)
end

local function get_filename(path)
    return string.match(path, "[^/]*$")
end

local function get_base_path(path)
    local filename_length = #get_filename(path)
    return string.sub(path, 0, -1 - filename_length)
end

local function get_source_hook_infos(source)
    local cd = obs.calldata_create()
    local proc = obs.obs_source_get_proc_handler(source)

    obs.proc_handler_call(proc, "get_hooked", cd)
    local hooked = obs.calldata_bool(cd, "hooked")
    local executable = obs.calldata_string(cd, "executable")
    local title = obs.calldata_string(cd, "title")

    obs.calldata_destroy(cd)

    return executable, title, hooked
end

local function search_for_capture_source_and_get_data()
    local process_name, window_name
    local sources = obs.obs_enum_sources()

    for _, source in ipairs(sources) do
        if obs.obs_source_active(source) then
            local tmp_process_name, tmp_window_title, tmp_hooked = get_source_hook_infos(source)

            if tmp_hooked then
                process_name = tmp_process_name
                window_name = tmp_window_title
            end
        end
    end

    return process_name, window_name
end

local function get_game_name()
    print("get_game_name()")

    local executable, title = search_for_capture_source_and_get_data()

    if executable ~= nil then
        print("\tExecutable: " .. executable)
    end
    if title ~= nil then
        print("\tWindow title: " .. title)
    end

    if cfg_name_source == name_source_enum["Process Name"] then
        return executable
    end

    return title
end

local function increment_filename(path)
    print("increment_filename(" .. path .. ")")
    -- If a file name exists, increment the file name
    --[[
    eg:
        filename(d).ext
        filename.ext --> filename(1).ext
        filename(9).ext --> filename(10).ext
    ]]
    -- Split the filename into the name and extension
    local name, ext = path:match("^(.-)(%.[^%.]*)$")

    -- If no extension is found, use the whole string as the name
    -- extension limit will be 5 characters.
    if ext ~= "" and #ext > 5 then
        name = path
        ext = ""
    end

    -- Check if the name already ends with a number in parentheses
    local baseName, number = name:match("(.+)%((%d+)%)$")

    local ret_str = ""
    if baseName and number then
        -- Increment the number
        number = tonumber(number) + 1
        ret_str = string.format("%s(%d)%s", baseName, number, ext)
    else
        -- Start with (1)
        ret_str = string.format("%s(1)%s", name, ext)
    end

    print("increment_filename() -> " .. ret_str)
    return ret_str
end

local function move_file(src, dst)
    print("move_file()")
    print("\t Src: " .. src)
    print("\t Dst: " .. dst)
    obs.os_mkdirs(get_base_path(dst))
    if not obs.os_file_exists(dst) then
        obs.os_rename(src, dst)
    else
        print("File aready exist at the destination! Increment the file and try again")
        dst = increment_filename(dst)
        -- recurse, try new file path name
        move_file(src, dst)
    end
end

local function sanitize_sub_directory_for_windows(path)
    -- sanatize path string for windows
    path = string.gsub(path, "^ +", "")          -- Remove leading whitespaces
    path = string.gsub(path, " +$", "")          -- Remove trailing whitespaces
    path = string.gsub(path, '[<>:\\/"|?*]', "") -- Remove illigal path characters for Windows
    return path
end

local function sanitize_string_for_ascii(input)
    -- Remove all non-ASCII alphanumeric characters and spaces
    local cleaned = input:gsub("[^%w%s]", " ")
    -- Replace multiple spaces with a single space
    cleaned = cleaned:gsub("%s+", " ")
    return cleaned
end

local function load_replacements(original_name)
    -- load the replacement values for the wildcards

    -- store current choice
    local store = cfg_name_source
    
    -- get the window title
    -- set to executable
    cfg_name_source = name_source_enum[ENUM_WINDOW_TITLE]
    replacements[WILDCARD_WINDOW_TITLE] = get_game_name()
    -- sanatize the window title
    replacements[WILDCARD_WINDOW_TITLE_ASCII] = sanitize_string_for_ascii(replacements[WILDCARD_WINDOW_TITLE])

    -- get the executable title
    -- set to executable
    cfg_name_source = name_source_enum[ENUM_PROCESS_NAME]
    replacements[WIDLCARD_EXECUTABLE] = get_game_name()
    -- sanatize the executable title
    replacements[WIDLCARD_EXECUTABLE_ASCII] = sanitize_string_for_ascii(replacements[WIDLCARD_EXECUTABLE])

    -- retore current choice
    cfg_name_source = store

    -- get original file name
    replacements[WILDCARD_ORIGINAL_FILE_NAME] = original_name
end

-- Function to replace wildcards in a string
local function replace_wildcards(input_string)
    return (input_string:gsub("%%[weoa]+", replacements))
end

local function organize(file_path, sub_dir)
    print("base_event(" .. file_path .. "/" .. sub_dir ")")
    -- Moves a given file to a new sub directory

    local game_name = get_game_name()
    local base_path = get_base_path(file_path)
    local original_file = get_filename(file_path)
    local insert_str = ""

    load_replacements(original_file)

    new_file_name = replace_wildcards(cfg_output_wildcards)

    if not game_name then
        return
    end

    if cfg_ascii_filter then
        game_name = sanitize_string_for_ascii(game_name)
    end

    if cfg_append_name then
        insert_str = "[" .. game_name .. "]"
    end

    local new_file_path = base_path
        .. "/"
        .. sanitize_sub_directory_for_windows(game_name)
        .. "/"
        .. sanitize_sub_directory_for_windows(sub_dir)
        .. "/"
        .. insert_str .. new_file_name

    move_file(file_path, new_file_path)
end

local function screenshot_event()
    print("screenshot_event()")

    local file_path = obs.obs_frontend_get_last_screenshot()
    organize(file_path, cfg_screenshot_sub_dir)
end

local function replay_event()
    print("replay_event()")

    local file_path = obs.obs_frontend_get_last_replay()
    organize(file_path, cfg_replay_sub_dir)
end

local function recording_event()
    print("recording_event()")

    local file_path = obs.obs_frontend_get_last_recording()
    organize(file_path, cfg_recording_sub_dir)
end

local function event_dispatch(event)
    if event == obs.OBS_FRONTEND_EVENT_SCREENSHOT_TAKEN then
        screenshot_event()
    elseif event == obs.OBS_FRONTEND_EVENT_REPLAY_BUFFER_SAVED then
        replay_event()
    elseif event == obs.OBS_FRONTEND_EVENT_RECORDING_STOPPED then
        if cfg_move_recordings then
            recording_event()
        end
    end
end

function script_load(settings)
    print("script_load()")
    obs.obs_frontend_add_event_callback(event_dispatch)
end
