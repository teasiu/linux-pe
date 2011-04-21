##���teasiu��Դ�������� teasiu@163.com
##�ò��񶼿��������Լ������
##�����������޸ı����룬�����뱣��ԭ������Ϣ��
##

!define NAME "PE2USB"
!define DISTRO "WINPE"
!define FILENAME "PE2USB"
!define VERSION "0.1"
!define MUI_ICON "usb48.ico"
RequestExecutionLevel highest ;�����û����Ȩ��
SetCompressor LZMA  ;ѹ����ʽ
CRCCheck On
XPStyle on  ;���xpϵͳʹ��ʱ����Ӧxp�ķ��
ShowInstDetails show
BrandingText "USBPEͨ�ð�װ�� ���teasiu��Ʒ"
CompletedText "��װ��������ӭʹ�ú��ղر�����!  --���teasiu"

InstallButtonText "�� ��" ;����һ����ť����Ϊ����

Name "${NAME} ${VERSION}"
OutFile "${FILENAME} ${VERSION}.exe"    ;���ɵ�exe�ļ���

!include "nsDialogs.nsh"
!include "MUI2.nsh"
!include "FileFunc.nsh"
!include "WordFunc.nsh" ;�����б�
; ҳ��ͷ����
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "usb-logo2.bmp"
!define MUI_HEADERIMAGE_BITMAP_NOSTRETCH
!define MUI_HEADERIMAGE_RIGHT   ;�ұ���ʾlogoͼ�꣬������ΪLEFT

; ����������
Var DestDriveTxt
Var DestDrive
Var DestDisk
Var LabelDrivePageText
Var LabelDriveSelect
Var Format
Var FormatMe
Var Hddmode  ;������������һ�����syslinuxģʽ
Var Zipmode  ;������������һ�����grub4dosģʽ
Var HddmodeMe
Var ZipmodeMe
Var Warning
Var Soft
Var Link
Var Links
Var Image
Var hImage
Var Iso
Var ISOFileTxt
Var ISOSelection
Var TheISO
Var ISOTest
Var ISOFile
var BootDir


Page custom drivePage  ;ֻ������һҳ


!define MUI_INSTFILESPAGE_COLORS "00FF00 000000"
; Instfiles page
!define MUI_TEXT_INSTALLING_TITLE $(Install_Title)
!define MUI_TEXT_INSTALLING_SUBTITLE $(Install_SubTitle)
!define MUI_TEXT_FINISH_SUBTITLE $(Install_Finish_Sucess)
!insertmacro MUI_PAGE_INSTFILES

; Language files
!insertmacro MUI_LANGUAGE "SimpChinese"  ;��֧������
LangString DrivePage_Title ${LANG_SIMPCHINESE} "��PE2USB��USBͨ��PE��װ��"
LangString DrivePage_Title2 ${LANG_SIMPCHINESE} "�Ȳ���һ��USB�̣�Ȼ���ٴ򿪱�������а�װ."
LangString DrivePage_Text ${LANG_SIMPCHINESE} "�����߽�ʹ����U����������."
LangString DrivePage_Input ${LANG_SIMPCHINESE} "��һ������������˵�ѡ������U��"
LangString Soft_Text ${LANG_SIMPCHINESE} "�ڶ�����ѡ������ISO���õ���������ģʽ����ѡ��"
LangString Iso_Text ${LANG_SIMPCHINESE} "��������ѡ������ISO�����ļ���"
LangString WarningPage_Text ${LANG_SIMPCHINESE} "ע�⣺��ȷ��U�������ѱ��ݡ�ԭ���Ͻ�����ȫ��д�����ɻָ���"
LangString Creation ${LANG_SIMPCHINESE} "���������ͽ�ѹISO�����ļ���U�̣����Ժ�"
LangString Install_Title ${LANG_SIMPCHINESE} "��װ�� ${DISTRO}"
LangString Install_SubTitle ${LANG_SIMPCHINESE} "���Ժ� ${NAME} ��װ ${DISTRO} �� $DestDisk"
LangString Install_Finish_Sucess ${LANG_SIMPCHINESE} "$\t ${NAME} �Ѿ���ɰ�װ${DISTRO}��$DestDisk"
LangString IsoFile ${LANG_SIMPCHINESE} "ISO�����ļ�|*.iso"
LangString Syslinux_Warning ${LANG_SIMPCHINESE} "һ������ ($R8) �����ڵ���װsyslinuxʱ.$\r$\n����USB����������������..$\r$\n����������U�̻��ʽ�����̺�����һ�Ρ�"
LangString grub4dos_Warning ${LANG_SIMPCHINESE} "һ������ ($R8) �����ڵ���װgrub4dosʱ.$\r$\n����USB����������������..$\r$\n����������U�̻��ʽ�����̺�����һ�Ρ�"

Function .onInit
  InitPluginsDir
  SetOutPath "$PLUGINSDIR"    ;��ʼʱ��������Դ������ʱ�ļ����Ա����ֱ�ӵ���
  File /r "src\*.*"
FunctionEnd

Function drivePage
  !insertmacro MUI_HEADER_TEXT $(DrivePage_Title) $(DrivePage_Title2)
  nsDialogs::Create 1018
  ${If} $DestDrive == ""
  GetDlgItem $6 $HWNDPARENT 1 ; ������һ���ľ��
  EnableWindow $6 0 ; �ر���һ����ť
  ${EndIf}
  ; ����bmp���λͼ
	${NSD_CreateBitmap} 75% 0 20% 100% ""
	Pop $Image
	${NSD_SetImage} $Image $PLUGINSDIR\ad.bmp $hImage
	
  ${NSD_CreateLabel} 0 0 70% 30 $(DrivePage_Text)
  Pop $LabelDrivePageText
  ${NSD_CreateLabel} 0 20 70% 15 $(DrivePage_Input)
  Pop $LabelDriveSelect
  SetCtlColors $LabelDriveSelect /Branding 0000BD  ; ��ɫ����
  
  ;���������˵�
  ${NSD_CreateDroplist} 0 40 30% 25 ""
  Pop $DestDriveTxt
  ${NSD_OnChange} $DestDriveTxt db_select.onchange
  ${GetDrives} "FDD" driveList  ;FDD��ʾ����ʾ�ƶ����̼�U��, HDD��ʾ��ʾ���ش��̼�Ӳ��, ALL��ʾ��ʾ���д���
  ${If} $DestDrive != ""
  ${NSD_CB_SelectString} $DestDriveTxt $DestDrive
  ${EndIf}

; ���Ӱ����������ַ����
  ${NSD_CreateLink} 85% 190 15% 14 "�������"
  Pop $Link
  ${NSD_OnClick} $Link onClickMyLink
; ��ʽ��ѡ��
  ${NSD_CreateButton} 32% 38 38% 22 "(��ѡ)FAT32��ʽ����U��"
  Pop $Format
  ${NSD_OnClick} $Format FormatIt
; ˵������
  ${NSD_CreateLabel} 0 70 70% 15 $(Soft_Text) ;�������,���������ǵ����������������
  Pop $Soft
  SetCtlColors $Soft /Branding 0000BD ;��ɫ
  
  ${NSD_CreateLabel} 0 115 70% 15 $(Iso_Text) ;����
  Pop $Iso
  SetCtlColors $Iso /Branding 0000BD ;��ɫ
  
  ${NSD_CreateText} 0 135 50% 20 "��������ص�*.iso�ĵ���ѡ��"
  Pop $ISOFileTxt

  ${NSD_CreateBrowseButton} 53% 135 65 20 "���"
  Pop $ISOSelection
  ${NSD_OnClick} $ISOSelection ISOBrowse

; ��������ģʽѡ��
  ${NSD_CreateCheckBox} 0 90 36% 15 "Syslinux����ģʽ."
  Pop $Hddmode
  ${NSD_Check} $Hddmode ; Ĭ�ϴ����
  ${NSD_OnClick} $Hddmode HddmodeIt

  ${NSD_CreateCheckBox} 38% 90 36% 15 "Grub4dos����ģʽ."
  Pop $Zipmode
  ${NSD_OnClick} $Zipmode ZipmodeIt

; ��ʾ��ǩ
  ${NSD_CreateLabel} 0 190 80% 14 $(WarningPage_Text)
  Pop $Warning
  EnableWindow $Format 0   ;�ر���ʾ
  EnableWindow $Hddmode 0
  EnableWindow $Zipmode 0
  EnableWindow $ISOFileTxt 0
  EnableWindow $ISOSelection 0
  ShowWindow $Warning 0
  GetDlgItem $6 $HWNDPARENT 3
  ShowWindow $6 0 ; ���λ�ȥ
  nsDialogs::Show
  ${NSD_FreeImage} $hImage  ; �ͷ�λͼ
FunctionEnd

Function ISOBrowse
 nsDialogs::SelectFileDialog open "$EXEDIR" $(IsoFile) ;������ͬĿ¼����ISO�ļ����Զ�ѡ��
 Pop $TheISO
 ${NSD_SetText} $ISOFileTxt $TheISO
 SetCtlColors $ISOFileTxt 009900 FFFFFF
 StrCpy $ISOTest "$TheISO"
 StrCpy $ISOFile "$TheISO" ; ����ѡ��ľ����ļ�ΪISOFile���Ա�����ѹ
 ${NSD_SetText} $Iso "��������ɣ�����ISO�����ļ���ѡ��."
 ${NSD_CreateLabel} 0 165 75% 14 "OK�������������"
  GetDlgItem $6 $HWNDPARENT 1 ; ������һ���ľ��
  EnableWindow $6 1 ; ����һ����ť
FunctionEnd

Function onClickMyLink
  Pop $Links ; Ϊ�˱������pop����
  ExecShell "open" "http://www.ecoo168.com"
FunctionEnd


Function db_select.onchange
  Pop $DestDriveTxt
  ${NSD_GetText} $DestDriveTxt $0
  StrCpy $DestDrive "$0"
  StrCpy $DestDisk "$DestDrive" -1
  EnableWindow $Format 1  ;����ʾ
  EnableWindow $Hddmode 1
  EnableWindow $Zipmode 1
  EnableWindow $ISOFileTxt 1
  EnableWindow $ISOSelection 1
  ShowWindow $Warning 1
  SetCtlColors $Warning /Branding FF0000
  Call HddmodeIt
  Call ZipmodeIt
FunctionEnd

;�̷��б���
Function driveList
	SendMessage $DestDriveTxt ${CB_ADDSTRING} 0 "STR:$9"
	Push 1
FunctionEnd

Function HddmodeIt
  ${NSD_GetState} $Hddmode $HddmodeMe
  
  ${If} $HddmodeMe == ${BST_CHECKED}
  ${NSD_Check} $Hddmode
  StrCpy $HddmodeMe "Yes"
  ${NSD_SetText} $Hddmode "(��ѡ)Syslinux����ģʽ"
  ${NSD_Uncheck} $Zipmode
  StrCpy $ZipmodeMe "No"
  ${NSD_SetText} $Zipmode "Grub4dos����ģʽ"
  
  ${ElseIf} $HddmodeMe == ${BST_UNCHECKED}
  ${NSD_Uncheck} $Hddmode
  StrCpy $HddmodeMe "No"
  ${NSD_SetText} $Hddmode "Syslinux����ģʽ"
  ${NSD_Check} $Zipmode
  StrCpy $ZipmodeMe "Yes"
  ${NSD_SetText} $Zipmode "(��ѡ)Grub4dos����ģʽ"
  ${EndIf}
FunctionEnd

Function ZipmodeIt ; Set Format2 Option
  ${NSD_GetState} $Zipmode $ZipmodeMe
  ${If} $ZipmodeMe == ${BST_CHECKED}
  ${NSD_Check} $Zipmode
  StrCpy $ZipmodeMe "Yes"
  ${NSD_SetText} $Zipmode "(��ѡ)Grub4dos����ģʽ"
  ${NSD_Uncheck} $Hddmode
  StrCpy $HddmodeMe "No"
  ${NSD_SetText} $Hddmode "Syslinux����ģʽ"
  ${ElseIf} $ZipmodeMe == ${BST_UNCHECKED}
  ${NSD_Uncheck} $Zipmode
  StrCpy $ZipmodeMe "No"
  ${NSD_SetText} $Zipmode "Grub4dos����ģʽ"
  ${NSD_Check} $Hddmode
  StrCpy $HddmodeMe "Yes"
  ${NSD_SetText} $Hddmode "(��ѡ)Syslinux����ģʽ"
  ${EndIf}
FunctionEnd

Function FormatIt ; ���ø�ʽ������
  Pop $FormatMe
  MessageBox MB_YESNO "��ʽ��U�̿���ȡ��ȫ���ռ䣬������" IDYES true IDNO false
true:
  Goto next
false:
  MessageBox MB_OK|MB_ICONSTOP "����ʽ�����˳�"
  Abort
next:
  MessageBox MB_YESNO "��ĸ�ʽ����(��ȷ������U�������Ѿ�����,��ʽ��������U�������Ҳ��ɻָ�)" /SD IDYES IDNO false2
  Goto next2
false2:
  MessageBox MB_OK|MB_ICONSTOP "����ʽ�����˳�"
  Abort
next2:  ;����fbinst�ĸ�ʽ��dos�����ϸ��ο�fbinst�Ĺٷ�˵��, fbinst����֧���̷�c:�ı�ʾ��ʽ��hd0,hd1�ı�ʾ��ʽ
  nsExec::ExecToLog '"cmd" /c "echo y|$PLUGINSDIR\fbinst $DestDisk format --raw --force --fat32"'
  MessageBox MB_OK "��ʽ����ɣ��ָ�U��ȫ���ռ䡣"
FunctionEnd

Function InstallEYes
  SetShellVarContext all
  StrCpy $R0 $DestDrive -1 ; ���̷������'\'�ַ���ȥ����ʾΪ��D: �ٶ���Ϊ$R0
  ClearErrors
  ${If} $HddmodeMe == "Yes"
    DetailPrint "����syslinux�������� $DestDisk, ���Ժ�"
   	ExecWait '$PLUGINSDIR\syslinux.exe -maf $R0' $R8   ; ����syslinux��dos�����У�������ο��ٷ�˵��
  	DetailPrint "Syslinux��װ������Ϣ���ֵ=$R8 , 0��ʾ�ɹ�"
    Banner::destroy
	${If} $R8 != 0  ; �������ֵ����0���򵯳�������ʾ��
    MessageBox MB_ICONEXCLAMATION|MB_OK $(Syslinux_Warning)
    DetailPrint "�����u�̻��ʽ��������һ�Ρ�"
  ${EndIf}
  Call syscopyfile
  ${ElseIf} $ZipmodeMe == "Yes"
  DetailPrint "����Grub4dos����ģʽ�������� $DestDisk, ���Ժ�"
	ExecWait '$PLUGINSDIR\BOOTICE.EXE /DEVICE=$R0 /mbr /install /type=grub4dos /auto' $R8  ; bootice֧�ֵ������У��кܶ��÷����ο��ٷ�
	DetailPrint "Grub4dos��װ������Ϣ���ֵ=$R8 , 0��ʾ�ɹ�"
	Banner::destroy
	${If} $R8 != 0 ; �������ֵ����0���򵯳�������ʾ��
  MessageBox MB_ICONEXCLAMATION|MB_OK $(grub4dos_Warning)
  DetailPrint "�����u�̻��ʽ��������һ�Ρ�"
  ${EndIf}
  Call grubcopyfile
  ${EndIf}
FunctionEnd

Function syscopyfile

  ${If} ${FileExists} "$BootDir\syslinux.cfg"
	;ʲôҲ����
  ${ElseIf} ${FileExists} "$BootDir\syslinux\syslinux.cfg"
  ;ʲôҲ����
  ${ElseIf} ${FileExists} "$BootDir\boot\syslinux\syslinux.cfg"
  ;ʲôҲ����
	${ElseIf} ${FileExists} "$BootDir\boot\isolinux\isolinux.cfg"
  Rename "$BootDir\boot\isolinux\" "$BootDir\boot\syslinux\"
  Rename "$BootDir\boot\syslinux\isolinux.cfg" "$BootDir\boot\syslinux\syslinux.cfg"
	${ElseIf} ${FileExists} "$BootDir\isolinux\isolinux.cfg"
	Rename "$BootDir\isolinux\" "$BootDir\syslinux\"
  Rename "$BootDir\syslinux\isolinux.cfg" "$BootDir\syslinux\syslinux.cfg"
  ${ElseIf} ${FileExists} "$BootDir\isolinux.cfg"
  Rename "$BootDir\isolinux.cfg" "$BootDir\syslinux.cfg"
	${Else} ; ������ļ���û��ʱ
	DetailPrint "û���ҵ�syslinux��׼�����ļ�syslinux.cfg"
	DetailPrint "����������װ��ISO����ʹ��syslinux������"
	DetailPrint "�����������ļ����޸�Ϊ��������ʹ���޷�ʶ��,"
	DetailPrint "�볢������������ʽ�����ֶ�Ѱ�Ҳ��༭�����ļ���"
	${EndIf}
	; �������syslinux��ͼ�β˵�,�Դﵽ�汾һ��
	${If} ${FileExists} "$BootDir\vesamenu.c32"
	CopyFiles "$PLUGINSDIR\vesamenu.c32" "$BootDir\vesamenu.c32"
	${ElseIf} ${FileExists} "$BootDir\syslinux\vesamenu.c32"
  CopyFiles "$PLUGINSDIR\vesamenu.c32" "$BootDir\syslinux\vesamenu.c32"
	${ElseIf} ${FileExists} "$BootDir\boot\syslinux\vesamenu.c32"
  CopyFiles "$PLUGINSDIR\vesamenu.c32" "$BootDir\boot\syslinux\vesamenu.c32"
	${EndIf}
FunctionEnd

Function grubcopyfile
;���Ҫ�����ļ���ȥ��������Դ����������Ӧ�ļ���������������
#  CopyFiles "$PLUGINSDIR\grldr" "$BootDir\grldr"
#  CopyFiles "$PLUGINSDIR\menu.lst" "$BootDir\menu.lst"
  
  ${If} ${FileExists} "$BootDir\grldr"
  ${ElseIf} ${FileExists} "$BootDir\grub\grldr"
  ${ElseIf} ${FileExists} "$BootDir\boot\grub\grldr"
  ${ElseIf} ${FileExists} "$BootDir\grub.exe"
  ${ElseIf} ${FileExists} "$BootDir\boot\grub.exe"
  ${ElseIf} ${FileExists} "$BootDir\boot\grub\grub.exe"
  ${Else} ; ���������һ�ļ���û��,��ʾ������ʾ
	DetailPrint "û���ҵ�grub4dos��׼�����ļ�grldr��"
	DetailPrint "����������װ��ISO����ʹ��grub4dos������"
	DetailPrint "�����������ļ����޸�Ϊ��������ʹ���޷�ʶ��,"
	DetailPrint "�볢������������ʽ�����ֶ�Ѱ�Ҳ��༭�����ļ���"
	${EndIf}
FunctionEnd

Section "Install" main
  StrCpy $BootDir $DestDrive -1 ; ���̷������'\'�ַ���ȥ����ʾΪ��D: �ٶ���Ϊbootdir
  StrCpy $BootDir "$BootDir"
  DetailPrint $(Creation)
  ExecWait '"$PLUGINSDIR\7zG.exe" x "$ISOFile" -o"$BootDir" -y -x![BOOT]*' ;��������7z�Զ���ѹISO�����ļ�������
  DetailPrint "���ڼ������ñ�׼�����ļ������Ժ�"
  Call InstallEYes

SectionEnd
