#!/usr/bin/env luajit
local ffi = require("ffi")
ffi.cdef[[
    typedef struct DIR DIR;

    struct dirent {
        unsigned long  d_ino;     // Номер inode
        long           d_off;     // Смещение
        unsigned short d_reclen;  // Длина записи
        unsigned char  d_type;    // Тип (папка, файл, ссылка и т.д.)
        char           d_name[256]; // Имя файла (массив байт)
    };
    int access(const char *pathname, int mode);
    DIR *opendir(const char *name);
    struct dirent *readdir(DIR *dirp);
    int closedir(DIR *dirp);
]]

-- Определяем путь относительно расположения скрипта
local script_dir = arg[0]:match("(.*/)" ) or "./"
local path = script_dir .. "../dependencies"

-- читаем дескрипторы каталога с директориями
local dir = ffi.C.opendir(path)
if dir == nil then
    print("Directory dont exist: " .. path)
    os.exit(1)
end

--[[
Переменная dir хранит указатель на структуру каталога (обычно DIR*),
который операционная система использует для отслеживания текущей
позиции при чтении содержимого папки
]]

-- передаем дескриптор каталога в функцию ffi.C.readdir внутри цикла
local function read_dir_entries(dirp)
    local base = {}

    while true do
        local entry = ffi.C.readdir(dirp)
        if entry == nil then break end
        local result = ffi.string(entry.d_name)
        if result ~= "." and result ~= ".." then
            table.insert(base, result)
        end
    end
    return base
end

local function full_path_func()
    local func_dir_path = {}
    local list = read_dir_entries(dir)
    for _, name in ipairs(list) do
        local result = path .. "/" .. name
        table.insert(func_dir_path, result)
    end
    return func_dir_path
end
local directory_path = full_path_func()

local function full_dp_path()
    local dp = {}
     for _, name in ipairs(directory_path) do
        local result = name .. "/.dp"
        table.insert(dp, result)
     end
    return dp
end
local dp_file_path = full_dp_path()

for _, name in ipairs(dp_file_path) do
    local test = io.open(name, "r")
    if test then
        local content = test:read("*a")
        print(content)
        test:close()
    end
end

ffi.C.closedir(dir)
