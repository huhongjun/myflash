@echo off
title ���Flah�����ļ�
echo #########################################################
echo  ���Flah�����ļ�·��(myTrustFile.cfg),�����ȫɳ������!
echo #########################################################
if not exist C:\"Documents and Settings"\%username%\"Application Data"\Macromedia\"Flash Player"\#Security\FlashPlayerTrust md C:\"Documents and Settings"\%username%\"Application Data"\Macromedia\"Flash Player"\#Security\FlashPlayerTrust
copy myTrustFile.cfg C:\"Documents and Settings"\%username%\"Application Data"\Macromedia\"Flash Player"\#Security\FlashPlayerTrust
pause