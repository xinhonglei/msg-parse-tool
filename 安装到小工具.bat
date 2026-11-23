@echo off
rem ============================================================
rem  本文件必须保存为 ANSI / GBK 编码 + CRLF 换行。
rem  若存成 UTF-8，cmd 会按 GBK 读成乱码，行被切断后直接闪退。
rem ============================================================
setlocal EnableExtensions
title 安装报文解析工具到接口小工具

set "BAD=0"
set "OKN=0"
set "FOUND="
set "SRC="
set "BASE="
set "ARG=%~1"

rem ---------- 1. 拖进来的对象优先 ----------
rem 拖进来一个 jetty 目录 -> 只装那一个；拖进来 html -> 当作源文件
if not "%ARG%"=="" if exist "%ARG%\" set "BASE=%ARG%"
if not "%ARG%"=="" if not exist "%ARG%\" if exist "%ARG%" set "SRC=%ARG%"

rem ---------- 2. 找源文件 html ----------
if not defined SRC call :pick "%~dp0"
if not defined SRC call :pick "D:\document\work\AI\WorkBuddy\msg-parse-tool"
if not defined SRC goto :nosrc

echo ============================================================
echo  报文解析生成工具 - 安装到接口小工具
echo  装完用 http://127.0.0.1:9988/msgparse/ 打开，才能读到返回
echo ============================================================
echo.
echo 源文件：%SRC%
echo.

rem ---------- 3. 找 jetty 目录 ----------
if not defined BASE if defined JETTY_BASE set "BASE=%JETTY_BASE%"
if not defined BASE if exist "D:\接口工具\" set "BASE=D:\接口工具"
if not defined BASE if exist "%~dp0接口工具\" set "BASE=%~dp0接口工具"

if not defined BASE goto :nobase

rem 拖进来的就是一个 jetty 目录
if exist "%BASE%\start.jar" if exist "%BASE%\webapps" goto :single

echo 搜索目录：%BASE%
for /d /r "%BASE%" %%d in (*) do (
  if exist "%%d\start.jar" if exist "%%d\webapps" (
    set "FOUND=1"
    call :install "%%d"
  )
)
if not defined FOUND goto :none
goto :summary

:single
set "FOUND=1"
call :install "%BASE%"
goto :summary

rem ---------- 汇总 ----------
:summary
echo.
echo ------------------------------------------------------------
if "%BAD%"=="0" (
  echo  安装完成，%OKN% 个目录已更新。
) else (
  echo  有 %BAD% 个目录没装上，见上面的 [失败] 行。
)
echo.
echo  使用步骤：
echo    1^) 双击 9988.bat 启动小工具（CIIS 或 RMSCI，都占 9988）
echo    2^) 浏览器打开 http://127.0.0.1:9988/msgparse/
echo    3^) 字段报文页填好报文，点「发送到接口」；或到接口页点「取当前报文」
echo.
echo  注意：浏览器按站点隔离存储。以前双击 html 时的协议库不会自动
echo        带过来，第一次请用顶栏「恢复」读入备份 json。
echo ------------------------------------------------------------
echo.
pause
exit /b 0

rem ---------- 找不到 jetty 目录 ----------
:none
echo.
echo ------------------------------------------------------------
echo  [未找到] %BASE% 下面没有 jetty 小工具目录。
echo.
echo  判断标准：该目录里同时有 start.jar 和 webapps 文件夹。
echo.
echo  请把 jetty-runner 文件夹直接拖到本 bat 图标上松开，
echo  它会只装那一个；拖「接口工具」整个文件夹也行，会自动搜。
echo ------------------------------------------------------------
echo.
pause
exit /b 2

:nobase
echo.
echo ------------------------------------------------------------
echo  [未找到] 这台机器上没有 D:\接口工具 目录。
echo.
echo  本 bat 只负责把页面塞进 jetty 的 webapps 目录。如果这台机器
echo  没装那两个接口小工具，安装这一步可以直接跳过：直接用 html
echo  改报文就行（只有「发送到接口」要用 9988 那边的页面）。
echo.
echo  如果确实装了、只是放在别处，请把 jetty-runner 文件夹拖到
echo  本 bat 图标上松开，就能装进去。
echo ------------------------------------------------------------
echo.
pause
exit /b 2

rem ---------- 找不到源文件 ----------
:nosrc
echo.
echo ------------------------------------------------------------
echo  [错误] 找不到「报文解析生成工具V*.html」。
echo.
echo  已找过这两个位置：
echo        %~dp0
echo        D:\document\work\AI\WorkBuddy\msg-parse-tool
echo.
echo  请把本 bat 和 html 放在同一个文件夹，或把 html 拖到本 bat 上。
echo ------------------------------------------------------------
echo.
pause
exit /b 1

rem ---------- 子过程：在指定目录里挑版本号最高的 html ----------
:pick
set "P=%~1"
if not "%P%"=="" if not exist "%P%\" set "P=%P%\"
for /f "delims=" %%f in ('dir /b /o-n /a-d "%P%报文解析生成工具V*.html" 2^>nul') do (
  if not defined SRC set "SRC=%P%%%f"
)
exit /b 0

rem ---------- 子过程：装到一个 jetty 目录 ----------
:install
set "ROOT=%~1"
set "DEST=%ROOT%\webapps\msgparse"
if not exist "%DEST%" mkdir "%DEST%" >nul 2>&1
copy /Y "%SRC%" "%DEST%\index.html" >nul 2>&1
if errorlevel 1 (
  echo [失败] %ROOT%
  echo        复制被拒绝。多半是 9988.bat 还开着，或没有写权限。
  echo        关掉那个黑窗口再试；仍失败就用管理员身份运行本 bat。
  set /a BAD+=1
  exit /b 1
)
echo [OK]   %ROOT%
echo        -^> %DEST%\index.html
set /a OKN+=1
exit /b 0
