@echo off
color 2f
title MXML�ļ������� by: Фƽ
mode con cols=80 lines=40
echo ********************************************************************************
echo *                     �������ɵ�swfλ��mxml�ļ������ļ�����                    *
echo *                                                by: Фƽ   %date%  *
echo ******************************************************************************** 
echo ע�⣺ʹ�ñ�����ǰ��ȷ����������flex sdk��������!
:begin
echo.
set filename=
set /p filename=������Ҫ�����mxml�ļ���������·�������·����:
echo.
mxmlc %filename%
echo.
set m=
set /p m=�����������, �˳��밴 1 :
if "%m%"=="1" goto end
goto begin
:end
exit