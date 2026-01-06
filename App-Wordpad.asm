;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@                                                                            @
;@                               W o r d p a d                                @
;@                                                                            @
;@             (c) 2012-2023 by Prodatron / SymbiosiS (Jörn Mika)             @
;@                                                                            @
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

;Todo
;- unlimited memory

;- clipboard with own type
;- search/replace (?!)


;- find nach doc-ende von vorne anfangen bis curpos
;- commands 29-31 focus setzen!

;Bugs
;- paste doesn't refresh screenparts


;--- PROGRAM-ROUTINES ---------------------------------------------------------
;### PRGKEY -> Check key
;### PRGINF -> show info-box
;### PRGEND -> quit application
;### PRGPAR -> Search for command line parameter (textfile)

;--- SUB-ROUTINES -------------------------------------------------------------
;### DIACNC -> Cancel dialogue
;### MSGGET -> check for message for application
;### CLCDEZ -> Converts byte into 2 decimal digits
;### CLCNUM -> Converts 16bit number into ASCII string (terminated by 0)
;### CLCR16 -> Converts string into 16bit number

;--- CONFIG-ROUTINES ----------------------------------------------------------
;### CFGGET -> Generates config path
;### CFGLOD -> Loads config
;### CFGINI -> Initialize config
;### CFGFNT -> Loads font
;### CFGSAV -> Save config
;### CFGOPN -> Open config-dialogue
;### CFGCOL -> Updates colour preview
;### CFGOKY -> Close config-dialogue and save config
;### CFGWRP -> Switch between "wrap at window border" and "no wrap"
;### CFGBAR -> Switches the status bar on/off

;--- FILE-ROUTINES ------------------------------------------------------------
;### FILMOD -> Ask for file-saving, if text has been modified
;### FILNEW -> New file
;### FILOPN -> Open file
;### FILSAS -> Save file as
;### FILSAV -> Save file
;### FILLOD -> load selected textfile
;### FILSTO -> save actual textfile
;### FILTIT -> Refreshes window title with filename

;--- EDIT-ROUTINES ------------------------------------------------------------
;### EDTCHG -> Editor changed
;### EDTCUT -> Edit Cut
;### EDTCOP -> Edit Copy
;### EDTPAS -> Edit Paste
;### EDTSAL -> Edit Select All
;### EDTDEL -> Edit Delete
;### EDTGOT -> Edit Goto
;### EDTTIM -> Edit Date/Time

;--- FIND- AND REPLACE-ROUTINES -----------------------------------------------
;### FNDFND -> Opens Find-Dialogue
;### FNDREP -> Opens Replace-Dialogue
;### FNDFOK -> Start Find
;### FNDROK -> Start Replace
;### FNDRDR -> Replace-Dialogue -> Replace
;### FNDRDA -> Replace-Dialogue -> Replace All
;### FNDRAL -> Start Replace all
;### FNDFNX -> Find next
;### FNDRPL -> Replaces text
;### FNDSEA -> Searches for text
;### FNDCAS -> Converts char into lcase, if case-flag is not set
;### FNDALN -> Checks, if word only + char is alphanumeric
;### FNDPLF -> Converts ^P into 13+10
;### FNDLFP -> Converts 13+10 into ^P
;### FNDGOT -> Goto

;--- DOCUMENT-ROUTINES --------------------------------------------------------
;### DOCINI -> initialise loaded document
;### DOCNEW -> clears and initialise document
;### DOCRFS -> refresh document display

;--- FONT STYLE ROUTINES ------------------------------------------------------
;### STYCUR -> check font style under cursor if wysiwyg, and set button if changed
;### STYRFR -> reformats the selected text with new font style
;### STYCVW -> convert all text to wysiwyg (cut <32, >126)
;### STYCVN -> convert all text to normal font
;### STY2AS -> convert WYSIWYG char to ASCII char
;### STY2NR -> convert normal/bold/italics/underlined style to normal style
;### STY2WY -> convert ASCII char to WYSIWYG char



;==============================================================================
;### CODE AREA ################################################################
;==============================================================================

keymapbld   ;**BOLD
db 0,0,0,0
db  32,127,128,129                          ;all
db 130,131,132,133,134,135,136,137,138, 45
db 140,141,142,143,144,145,146,147,148,149
db 150,151,152,153,154, 61,156,157,158,159
db 160,161,162,163,164,165,166,167,168,169
db 170,171,172,173,174,175,176,177,178,179
db 180,181,182,183,184,185,186,187,188, 95
db  96,191,192,193,194,195,196,197,198,199
db 200,201,202,203,204,205,206,207,208,209
db 210,211,212,213,214,215,216,217,218,219

keymapita   ;**ITALICS
db 0,0,0,0
db 32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47
db 220,221,222,223,224,225,226,227,228,229  ;0-9
db 58,59,60,61,62,63,64
db 230,231,232,233,234,235,236,237,238,239,240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255  ;A-Z
db 91,92,93,94,95,96
db 230,231,232,233,234,235,236,237,238,239,240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255  ;A-Z
db 123,124,125,126

keymapuln   ;**UNDERLINED
db 0,0,0,0
db 190,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47
db "0123456789"
db 58,59,60,61,62,63,64
db 1,2,3,4,5,6,7,8,9,27,11,12,28,14,15,16,17,18,19,20,21,22,23,24,25,26     ;A-Z
db 91,92,93,94,95,96
db 1,2,3,4,5,6,7,8,9,27,11,12,28,14,15,16,17,18,19,20,21,22,23,24,25,26     ;A-Z
db 123,124,125,126

;### PRGPRZ -> Application process
maiwinnum   db 0    ;main     window ID
drpwinnum   db -1   ;font downdown w ID
diawin      db 0    ;dialogue window ID
tmpwin      db -1   ;print window
windatsup   equ 51

prgprz  call prglng
        call prgpar
        call cfglod
        call cfgini
        call SySystem_HLPINI

        ld a,(App_BnkNum)
        ld de,prgwindat
        call SyDesktop_WINOPN
        jp c,prgend             ;memory full -> quit process
        ld (maiwinnum),a           ;window has been opened -> store ID

        ld a,(prgparf)
        or a
        call nz,fillod
        call edtchg1

prgprz1 call msgget             ;*** check for messages
        jr c,prgprz2
        jr prgprz1
prgprz0 rst #30
        call msgget0
        jr c,prgprz2
        call edtchg0
        jr prgprz1
prgprz2 cp MSR_DSK_WMODAL
        jr z,prgprz5
        cp MSR_DSK_WCLICK       ;* window has been clicked?
        jr nz,prgprz0
        ld a,(diawin)
        cp (iy+1)
        ld a,(iy+2)
        jr nz,prgprz3
        cp DSK_ACT_CLOSE        ;* setup-close clicked
        jp z,diacnc
prgprz3 cp DSK_ACT_CLOSE        ;* main-close clicked
        jp z,prgend0
        cp DSK_ACT_MENU         ;* menu has been clicked
        jr z,prgprz4
        cp DSK_ACT_KEY          ;* key has been clicked
        jr z,prgkey
        cp DSK_ACT_TOOLBAR      ;* toolbar has been clicked
        jr z,prgprz4
        cp DSK_ACT_CONTENT      ;* content clicked
        jr nz,prgprz0
prgprz4 ld l,(iy+8)
        ld h,(iy+9)
        ld a,l
        or h
        jr z,prgprz0
        inc h:dec h
        jr z,prgprz6
        ld a,(iy+3)             ;A=click type (0/1/2=mouse left/right/double, 7=keyboard)
        jp (hl)
prgprz5 ld hl,(App_MsgBuf+1)    ;* close dropdown if user clicked outside
        ld a,(drpwinnum)
        cp l
        jr nz,prgprz0
        call drpclo
        jr prgprz0
prgprz6 ld a,l                  ;* dropdown entry has been clicked
        jp drpclk


;### PRGKEY -> Check key
prgkeya equ 8
prgkeyt db "N"-64:dw filnew ;CTRL+N = New
        db "O"-64:dw filopn ;CTRL+O = Open
        db "S"-64:dw filsav ;CTRL+S = Save
        db "F"-64:dw fndfnd ;CTRL+F = Find
        db 143:dw fndfnx    ;F3     = Find next
        db "R"-64:dw fndrep ;CTRL+R = Replace
        db 158:dw edtgot    ;ALT+G  = Goto
        db 145:dw edttim    ;F5     = Date/Time

prgkey  ld hl,prgkeyt
        ld b,prgkeya
        ld de,3
        ld a,(iy+4)
prgkey1 ld c,(hl)
        cp c
        jr z,prgkey2
        add hl,de
        djnz prgkey1
        jp prgprz0
prgkey2 inc hl
        ld a,(hl)
        inc hl
        ld h,(hl)
        ld l,a
        ld a,7
        jp (hl)

;### PRGHLP -> show help
prghlp  call SySystem_HLPOPN
        jp prgprz0

;### PRGINF -> show info-box
prginf  ld hl,prgtxtinf         ;*** info box
        ld b,1+128+64
prginf1 call prginf0
        jp prgprz0
prginf0 ld a,(App_BnkNum)
        ld de,prgwindat
        jp SySystem_SYSWRN

;### PRGEND -> quit application
prgend0 call filmod
        jp c,prgprz0
prgend  ld hl,(App_BegCode+prgpstnum)
        call SySystem_PRGEND
prgend1 rst #30                     ;wait for death
        jr prgend1

;### PRGPAR -> Search for command line parameter (textfile)
prgparf db 0                    ;flag, if command line parameter exists

prgpar  ld hl,(App_BegCode)     ;search for command line parameter
        ld de,App_BegCode
        dec h
        add hl,de               ;HL=code area end=path
        ld b,255
prgpar1 ld a,(hl)
        or a
        ret z
        cp 32
        jr z,prgpar2
        inc hl
        djnz prgpar1
        ret
prgpar2 ld (hl),0
        inc hl
        ld de,docpth
        ld bc,255
        ld a,c
        ld (prgparf),a
        ldir
prgpar3 ret

;### PRGLNG -> load language pack
prglng  ld hl,(App_BegCode)
        ld de,App_BegCode
        dec h
        add hl,de               ;HL=code area end=path
        ex de,hl
        ld a,(App_BnkNum)
        ld c,a
        ld hl,texts_int
        ld ix,256*0+9           ;default language=9 (english), pack=0
        ld iyl,0                ;language-file version 0
        jp SySystem_LNGLOD


;==============================================================================
;### SUB-ROUTINES #############################################################
;==============================================================================

;### DIACNC -> Cancel dialogue
diacnc  ld a,(diawin)
        call SyDesktop_WINCLS
        jp prgprz0

;### MSGGET -> check for message for application
;### Output     CF=0 -> no message, CF=1 -> IXH=sender, (App_MsgBuf)=message, A=(App_MsgBuf+0), IY=App_MsgBuf
msgget  call msgget2            ;** sleep
        rst #08
        jr msgget1
msgget0 call msgget2            ;** no sleep
        rst #18                 ;get Message -> IXL=Status, IXH=sender ID
msgget1 or a
        db #dd:dec l
        ret nz
        ld iy,App_MsgBuf
        ld a,(iy+0)
        or a
        jp z,prgend
        scf
        ret
msgget2 ld a,(App_PrcID)
        db #dd:ld l,a           ;IXL=our own process ID
        db #dd:ld h,-1          ;IYL=sender ID (-1 = receive messages from any sender)
        ld iy,App_MsgBuf           ;IY=Messagebuffer
        ret

;### CLCDEZ -> Converts byte into 2 decimal digits
;### Input      A=Value
;### Output     L=10-digit, H=1-digit
;### Destroyed  AF
clcdez  ld l,0
clcdez1 sub 10
        jr c,clcdez2
        inc l
        jr clcdez1
clcdez2 add "0"+10
        ld h,a
        ld a,"0"
        add l
        ld l,a
        ret

;### CLCNUM -> Converts 16bit number into ASCII string (terminated by 0)
;### Input      IX=value, IY=address, E=max digits
;### Output     (IY)=last digit
;### Destroyed  AF,BC,DE,HL,IX,IY
clcnumt dw 1,10,100,1000,10000
clcnum  ld d,0
        ld b,e
        dec e
        push ix
        pop hl
        ld ix,clcnumt
        add ix,de
        add ix,de               ;IX=first divider
        dec b
        jr z,clcnum4
        ld c,0
clcnum1 ld e,(ix)
        ld d,(ix+1)
        dec ix
        dec ix
        ld a,"0"
        or a
clcnum2 sbc hl,de
        jr c,clcnum5
        inc c
        inc a
        jr clcnum2
clcnum5 add hl,de
        inc c
        dec c
        jr z,clcnum3
        ld (iy+0),a
        inc iy
clcnum3 djnz clcnum1
clcnum4 ld a,"0"
        add l
        ld (iy+0),a
        ld (iy+1),0
        ret

;### CLCR16 -> Converts string into 16bit number
;### Input      IX=string, A=terminator, BC=min (>=0), DE=max (<=65534)
;### Output     IX=string behind terminator, HL=number, CF=1 -> invalid (too big/small, wrong chars/terminator)
;### Destroyed  AF,DE,IYL
clcr16  ld hl,0
        db #fd:ld l,a
clcr161 ld a,(ix+0)
        inc ix
        db #fd:cp l
        jr z,clcr163
        sub "0"
        ret c
        cp 10
        ccf
        ret c
        push bc
        add hl,hl:jr c,clcr162
        ld c,l
        ld b,h
        add hl,hl:jr c,clcr162
        add hl,hl:jr c,clcr162
        add hl,bc:jr c,clcr162
        ld c,a
        ld b,0
        add hl,bc:ret c
        pop bc
        jr clcr161
clcr162 pop bc
        ret
clcr163 sbc hl,bc
        ret c
        add hl,bc
        inc de
        sbc hl,de
        ccf
        ret c
        add hl,de
        or a
        ret


;==============================================================================
;### DROPDOWN ROUTINES ########################################################
;==============================================================================

fntcfgnum equ 11

;### DRIFNT -> inits font dropdown window
drifnt  ld ix,fntcolrec+16  ;gui records
        ld hl,bmpfnttab     ;bitmap adr tab
        ld bc,256*fntcfgnum
drifnt1 call drifnt0
        ld a,(iy-1)         ;a=yofs
        add c
        ld (ix+8),a
        ld de,16
        add ix,de
        ld a,c
        add 10
        ld c,a
        djnz drifnt1
drifnt2 ld a,(cfgdatfnt)    ;selected font
        add a
        ld c,a
        add a
        add a
        add c               ;a*=10
        ld (fntcfgnum*16+fntcolrec+16+8),a  ;place marker on selected font
        ret
drifnt0 ld e,(hl)
        inc hl
        ld d,(hl)
        push de:pop iy      ;de/iy=bitmap address
        inc hl
        ld (ix+4+0),e
        ld (ix+4+1),d
        ld a,(iy+1)
        ld (ix+10),a
        ld a,(iy+2)         
        ld (ix+12),a        ;store xl/yl
        ret

;### DRPFNT -> opens font dropdown
drpfnt  call drifnt
        ld a,(prgwindat+0)
        cp 2
        ld hl,-1
        ld e,l
        ld d,h
        jr z,drpfnt1
        ld hl,(prgwindat+4)
        ld de,(prgwindat+6)
drpfnt1 ld bc,54
        add hl,bc
        ld (fntwindat+4),hl
        ex de,hl
        ld bc,32
        add hl,bc
        ld (fntwindat+6),hl
        ld de,fntwindat
        ld a,(App_BnkNum)
        call SyDesktop_WINOPN   ;open dropdown window
        jp c,prgprz0
        ld (drpwinnum),a
        inc a
        ld (prgwindat+51),a
        jp prgprz0

;### DRPCLK -> dropdown entry has been clicked
;### Input      A=entry code (1-x, -1=marked entry)
drpclk  push af
        call drpclo
        rst #30
        pop af
        cp -1
        jp z,prgprz0
        dec a
        call styfnt
        jp prgprz0

;### DRPCLO -> close dropdown window
drpclo  ld hl,drpwinnum
        ld a,(hl)
        ld (hl),-1
        jp SyDesktop_WINCLS   ;close dropdown window


;==============================================================================
;### FONT STYLE ROUTINES ######################################################
;==============================================================================

stytyp  db 0    ;0=normal, 1=bold, 2=italics, 3=underlined

styfnt  ld hl,cfgdatfnt             ;A=new font style
        cp (hl)
        ret z
        ld (hl),a
        push af
        call cfgfnt
        pop af
styfnt0 dec a
        jr nz,styfnt1
        call stycvw                 ;convert to wysiwyg (cut <32, >126)
        jr styfnt2
styfnt1 call stycvn                 ;convert to normal font
        call stytog0
styfnt2 ld de,256*prgtolrec_fntdrp+255-2
        ld a,(maiwinnum)
        call SyDesktop_WINTOL
        jp docrfs

stybld  ld c,1                      ;button "bold" clicked
        jr stymrk0
styita  ld c,2                      ;button "italics" clicked
        jr stymrk0
styuln  ld c,3                      ;button "underlined" clicked
        jr stymrk0
stymrk  ld c,0                      ;marked button clicked -> deactivate
stymrk0 call stytog
        call styrfr
        jp prgprz0

stytog  ld a,c                      ;C=style -> toggle button
        sub 1
        jr c,stytog0
        ld de,0*16+prgtolrecp+2
        ld ix,keymapbld
        jr z,stytog1
        ld de,1*16+prgtolrecp+2
        ld ix,keymapita
        sub 2
        jr c,stytog1
        ld de,2*16+prgtolrecp+2
        ld ix,keymapuln
stytog1 ld a,(cfgdatfnt)            ;toggle button
        dec a
        ret nz
        ld hl,stytyp
        ld a,c
        cp (hl)
        jr nz,stytog2
stytog0 xor a                       ;deactivate buttons
        ld de,-16
stytog2 ld (stytyp),a
        ld (prgtolrec0+6),de
        ld hl,txtmulobj+texdatflg
        res 4,(hl)
        or a
        jr z,stytog3
        set 4,(hl)
        ld (txtmulobj+texdatkmp),ix
stytog3 ld a,(maiwinnum)
        ld de,256*prgtolreci+256-prgtolrecn-1
        jp SyDesktop_WINTOL

;### STYCHR -> check the style of a WYSIWYG char
;### Input      A=char
;### Output     A=type (0=normal, 1=bold, 2=italics, 3=underlined)
;### Destroyed  F,C,HL
stychr  ld c,a
        push af
        call stycur7        ;zf -> normal
        jr z,stychr1
        pop af
        call stycur6        ;c=type (0=normal, 1=bold, 2=italics, 3=underlined)
        ld a,c
        ret
stychr1 pop af
        xor a
        ret

;### STYCUR -> check font style under cursor if wysiwyg, and set button if changed
stycurign
        db 30,31,139,155    ;arrows
        db 29,32,189        ;spaces (1,3,8 pixels)
        db 95,96            ;both in normal and bold
        db 10,13,0          ;line feed, terminator

stycur  ld a,(cfgdatfnt)
        dec a
        ret nz
        ld hl,(txtmulobj+texdatpos)
        ld a,l
        or h
        jr z,stycur1
        dec hl
stycur1 ld de,txtbufmem
        add hl,de
        ld c,(hl)
        ld a,10
        cp c
        jr nz,stycur2
        inc hl
        ld c,(hl)
stycur2 call stycur7
        ret z
        ld hl,stytyp
        ld b,(hl)           ;b,(hl)=current style
        ld a,c
        call stycur6
        ld hl,stytyp
        ld a,(hl)
        cp c
        ret z
        jp stytog

stycur7 ld hl,stycurign     ;** c=char -> not a special one?-> zf->yes ignore, nz->special one
stycur3 ld a,(hl)
        cp c
        ret z
        inc hl
        or a
        jr nz,stycur3
        inc a
        ret

;a=char (0-255) -> c=type (0=normal, 1=bold, 2=italics, 3=underlined)
stycur6 ld c,3              ;001-028 -> underlined
        cp 28+1
        ret c
        cp 190
        ret z
        ld c,0              ;033-126 -> normal, if current has same chars
        cp 127
        jr nc,stycur5
        dec b
        ret z               ;old was bold -> for all 33-126 switch to normal
        dec b
        dec b
        jr z,stycur4        ;old was underlined -> switch for a-z, A-Z to normal
        inc b
        ret nz
        cp "0"              ;old was italics -> switch for 0-9, a-z, A-Z to normal
        ret c
        cp "9"+1
        ret c
stycur4 cp "A"
        ret c
        cp "Z"+1
        ret c
        cp "a"
        ret c
        cp "z"+1
        ret c
        ret
stycur5 ld c,1              ;127-219 -> bold
        cp 220
        ret c
        inc c               ;220-255 -> italics
        ret

;### STYRFR -> reformats the selected text with new font style
styrfr  ld a,(cfgdatfnt)            ;toggle button
        dec a
        ret nz                      ;not wysiwyg -> no conversion
        ld hl,(txtmulobj+texdatmrk)
        ld a,l:or h
        ret z                       ;no marked text -> no conversion
        ex de,hl
        ld hl,(txtmulobj+texdatpos)
        bit 7,d
        jr z,styrfr1
        add hl,de
        ld a,e:cpl:ld e,a
        ld a,d:cpl:ld d,a
        inc de
styrfr1 ld bc,txtbufmem
        add hl,bc                   ;hl=first char, de=length
        ld bc,(stytyp-1)            ;b=style
styrfr2 ld a,(hl)
        call sty2nr
        ld c,b
        call sty2wy
        ld (hl),a
        inc hl
        dec de
        ld a,e
        or d
        jr nz,styrfr2
        jp docrfs

;### STYCVW -> convert all text to wysiwyg (cut <32, >126)
stycvw  ld hl,txtbufmem
        ld de,(txtmulobj+texdatlen)
stycvw1 ld a,e
        or d
        ret z
        ld a,(hl)
        cp 10
        jr z,stycvw3
        cp 13
        jr z,stycvw3
        cp 32
        jr c,stycvw2
        cp 126+1
        jr c,stycvw3
stycvw2 ld a,"?"
stycvw3 ld (hl),a
        inc hl
        dec de
        jr stycvw1

;### STYCVN -> convert all text to normal font
stycvn  ld hl,txtbufmem
        ld de,(txtmulobj+texdatlen)
stycvn1 ld a,e
        or d
        ret z
        ld a,(hl)
        call sty2as
        ld (hl),a
        inc hl
        dec de
        jr stycvn1

;### STY2AS -> convert WYSIWYG char to ASCII char
;### Input      A=char (0-255)
;### Output     A=ASCII code (0, 10, 13, 33-126)
sty2as  or a
        ret z
        cp 10
        ret z
        cp 13
        ret z           ;ignore 0/10/13
        cp 28+1
        jr nc,sty2as2
        cp 27           ;1-28 **UNDERLINED**
        jr c,sty2as1
        ld a,10
        jr z,sty2as1
        ld a,13
sty2as1 add "A"-1
        ret
sty2as2 jr nz,sty2as4
sty2as3 ld a," "        ;space -> return " "
        ret
sty2as4 cp 32
        jr nc,sty2as6
sty2as5 cp 030:jr z,styaup
        cp 031:jr z,styadw
        cp 139:jr z,styalf
        cp 155:jr z,styarg
        ld a,"?"        ;special -> return "?"
        ret
sty2as6 cp 126+1
        ret c           ;32-126 ** NORMAL **
        cp 139
        jr z,sty2as5
        cp 155          ;special -> return "?"
        jr z,sty2as5
        cp 189
        jr z,sty2as3
        cp 190          ;space -> return " "
        jr z,sty2as3
        cp 220
        jr nc,sty2nr3   ;220-255 **ITALICS**
        add 33-127      ;127-219 **BOLD**
        ret
styaup  ld a,"^":ret
styadw  ld a,"v":ret
styalf  ld a,"<":ret
styarg  ld a,">":ret

;### STY2NR -> convert normal/bold/italics/underlined style to normal style
;### Input      A=char
;### Output     A=normal styled char
;### Destroyed  F
sty2nr  or a
        ret z
        cp 10
        ret z
        cp 13
        ret z           ;ignore 0/10/13
        cp 28+1
        jr nc,sty2nr2
        cp 27           ;1-28 **UNDERLINED**
        jr c,sty2nr1
        ld a,10
        jr z,sty2nr1
        ld a,13
sty2nr1 add "A"-1
        ret
sty2nr2 cp 126+1
        ret c           ;32-126 ** NORMAL **
        cp 139
        ret z
        cp 155          ;special -> keep it
        ret z
        cp 189
        ret z
        cp 190          ;space -> keep it
        ret z
        cp 220
        jr nc,sty2nr3
        add 33-127      ;127-219 **BOLD**
        ret
sty2nr3 cp 230          ;220-255 **ITALICS**
        jr nc,sty2nr4
        add "0"-220
        ret
sty2nr4 add "A"-230
        ret

;### STY2WY -> convert ASCII char to WYSIWYG char
;### Input      A=normal ascii char (32-126), C=style (0=normal, 1=bold, 2=italics, 3=underlined)
;### Output     A=char (0-255)
;### Destroyed  F,C
sty2wy  inc c:dec c
        ret z
        cp 33
        ret c
        cp 126+1
        ret nc          ;ignore <33, >126
        dec c
        jr nz,sty2wy1
        cp 45           ;** BOLD **
        ret z
        cp 61
        ret z
        cp 95
        ret z
        cp 96           ;ignore -=_'
        ret z
        add 127-33
        ret
sty2wy1 dec c
        jr nz,sty2wy4
        cp "0"          ;** ITALICS **
        ret c
        cp "9"+1
        jr nc,sty2wy2
        add 220-"0"
        ret
;CF=1 no changes, CF=0 A=italics A-Z
sty2wy2 cp "A"
        ret c
        cp "Z"+1
        jr nc,sty2wy3
        add 230-"A"
        ret
sty2wy3 cp "a"
        ret c
        cp "z"+1
        ccf
        ret c
        add 230-"a"
        ret
sty2wy4 call sty2wy2    ;** UNDERLINED **
        ret c
        add 1-230
        cp 10
        ld c,27
        jr z,sty2wy5
        cp 13           ;replace 10,13 -> 27,28
        ret nz
        inc c
sty2wy5 ld a,c
        ret


;==============================================================================
;### CONFIG-ROUTINES ##########################################################
;==============================================================================

cfgnam  db "wordpad.dat",0:cfgnam0
cfgpth  dw 0

;### CFGGET -> Generates config path
cfgget  ld hl,(App_BegCode)
        ld de,App_BegCode
        dec h
        add hl,de           ;HL = CodeEnd = path
        ld (cfgpth),hl
        ld e,l
        ld d,h              ;DE=HL
        ld b,255
cfgget1 ld a,(hl)           ;search end of path
        or a
        jr z,cfgget2
        inc hl
        djnz cfgget1
        jr cfgget4
        ld a,255
        sub b
        jr z,cfgget4
        ld b,a
cfgget2 ld (hl),0
        dec hl              ;search start of filename
        call cfgget5
        jr z,cfgget3
        djnz cfgget2
        jr cfgget4
cfgget3 inc hl
        ex de,hl
cfgget4 ld hl,cfgnam        ;replace application filename with config filename
        ld bc,cfgnam0-cfgnam
        ldir
        ret
cfgget5 ld a,(hl)
        cp "/"
        ret z
        cp "\"
        ret z
        cp ":"
        ret

;### CFGLOD -> Loads config
cfglod  call cfgget
        ld hl,(cfgpth)
        ld a,(App_BnkNum)
        db #dd:ld h,a
        call SyFile_FILOPN          ;open file
        ret c
        ld hl,cfgdat
        ld bc,256
        ld de,(App_BnkNum)
        push af
        call SyFile_FILINP          ;load configdata
        pop af
        call SyFile_FILCLO          ;close file
        ret

;### CFGINI -> Initialize config
cfgini  ld hl,prgwinmen4+2
        ld de,cfgdatsta
        ld a,(de)
        add a
        res 1,(hl)
        or (hl)
        ld (hl),a
        and 2
        call cfgbar1
        jr nz,cfgini0
        ld de,10
        ld hl,(prgwindat+10)
        add hl,de
        ld (prgwindat+10),hl
cfgini0 ld hl,(cfgdatpap)
        ld a,h
        add a:add a:add a:add a
        add l
        ld (txtmulobj+texdatcol),a
        ld a,(cfgdattab)
        ld (txtmulobj+texdattab),a
        ld hl,txtmulobj+texdatfg2
        res 0,(hl)
        ld a,(cfgdatwrp)
        cp 1
        jr c,cfgini2
        set 0,(hl)
        ld hl,-1
        jr nz,cfgini1
        ld hl,(cfgdatwps)
cfgini1 ld (txtmulobj+texdatxmx),hl
cfgini2 ld a,(cfgdatfnt)
        ld (fntdrpobj+12),a
        ld a,(cfgfntnum)
        inc a
        ld (fntselobj),a
        ld (fntdrpobj),a
        dec a
        jr z,cfgfnt
        db #fd:ld l,a
        add a
        add a
        ld l,a
        ld h,0
        ld de,cfgfntdat
        add hl,de
        ld ix,fntsellst+4
        xor a
cfgini3 ld (ix+2),l
        ld (ix+3),h
        ld de,4
        add ix,de
        ld bc,-1
        cpir
        db #fd:dec l
        jr nz,cfgini3
        call cfgwrp0
        jr cfgfnt

;### CFGFNT -> Loads font
cfgfntl db -1   ;last loaded font
cfgfnt  ld hl,txtmulobj+texdatflg
        res 3,(hl)
        ld a,(cfgdatfnt)
        or a
        jr z,cfgfnt2
        ld hl,cfgfntl
        cp (hl)
        jp z,cfgfnt1
        push af
        ld hl,(cfgpth)
        ld a,(App_BnkNum)
        db #dd:ld h,a
        call SyFile_FILOPN          ;open file
        pop bc
        ret c
        push af
        ld l,b
        sla l
        sla l
        ld h,0
        ld c,h
        ld de,cfgfntdat-4
        add hl,de                   ;hl=font size, offset
        ld b,(hl)                   ;b=number of chars
        inc hl
        inc hl
        ld e,(hl):db #dd:ld l,e
        inc hl
        ld e,(hl):db #dd:ld h,e     ;ix=offset in file
        ld l,b
        ld h,c
        add hl,hl
        add hl,hl
        add hl,hl
        inc hl                      ;2byte header
        add hl,hl                   ;hl=chars*16+2=fontlen
        push hl
        ld iy,0
        call SyFile_FILPOI          ;move to font data
        ld hl,txtbufmem
        ld de,txtbufmax+1
        push af
        add hl,de
        pop af
        pop bc                      ;bc=fontlen
        pop de
        jr c,cfgfnt0
        ld (txtmulobj+texdatfnt),hl
        ld a,(cfgfntcpr)
        sub 1
        ccf                         ;cf=compressed
        ld a,d                      ;a=file handler
        ld de,(App_BnkNum)
        push af
        call SyFile_FILCPR          ;load font
        pop bc
        jr c,cfgfnt0
        call cfgfnt1
        ld a,(cfgdatfnt)
        ld (cfgfntl),a
cfgfnt0 ld a,b
        call SyFile_FILCLO          ;close file
cfgfnt2 ld a,(cfgdatfnt)            ;update selected dropdown entry
        add a
        ld l,a
        ld h,0
        ld de,bmpfnttab
        add hl,de
        ld ix,prgtolrec_fntdrp_adr+16
        call drifnt0
        ld a,(iy-1)
        add 3
        ld (ix+8),a
        jp drifnt2                  ;update marked entry in dropdown
cfgfnt1 ld hl,txtmulobj+texdatflg
        set 3,(hl)
        ret

;### CFGSAV -> Save config
cfgsav  ld hl,(cfgpth)      ;open config file
        ld a,(App_BnkNum)
        db #dd:ld h,a
        xor a
        call SyFile_FILOPN
        ret c
        ld de,(App_BnkNum)   ;save config
        ld hl,cfgdat
        ld bc,16
        push af
        call SyFile_FILOUT
        pop af              ;close config file
        call SyFile_FILCLO
        ret

;### CFGOPN -> Open config-dialogue
cfgopn  ld a,(cfgdatwrp)
        ld (cfgwinwrp),a
        ld ix,(cfgdatwps)
        ld iy,cfgwinbuf1
        ld e,4
        call cfgopn1
        ld ix,(cfgdattab)
        db #dd:ld h,0
        ld iy,cfgwinbuf2
        ld e,2
        call cfgopn1
        ld bc,(fntselobj-1)
        ld hl,fntsellst+1
        ld de,4
cfgopn2 res 7,(hl)
        add hl,de
        djnz cfgopn2
        ld a,(cfgdatfnt)
        ld (fntselobj+12),a
        add a:add a
        ld l,a
        ld h,0
        ld de,fntsellst+1
        add hl,de
        set 7,(hl)
        ld a,(cfgdatpap)
        ld (papselobj+12),a
        ld c,a
        ld a,(cfgdatpen)
        ld (penselobj+12),a
        call cfgcol0
        ld de,cfgwindat
cfgopn0 ld a,(App_BnkNum)
        call SyDesktop_WINOPN
        jp c,prgprz0            ;memory full -> ignore
        ld (diawin),a           ;window has been opened -> store ID
        inc a
        ld (prgwindat+windatsup),a
        jp prgprz0
cfgopn1 push iy
        call clcnum
        ex (sp),iy
        pop hl
        db #fd:ld e,l
        db #fd:ld d,h
        or a
        sbc hl,de
        inc l
        ld (iy-6),l
        ld (iy-10),l
        ret

;### CFGCOL -> Updates colour preview
cfgcol  call cfgcol0
        ld a,(diawin)
        ld e,8
        call SyDesktop_WINDIN
        jp prgprz0
cfgcol0 ld a,(penselobj+12)
        add a:add a:add a:add a
        ld hl,papselobj+12
        add (hl)
        ld (cfgwindsc8+2),a
        ret

;### CFGOKY -> Close config-dialogue and save config
cfgoky  ld a,(cfgwinwrp)
        ld (cfgdatwrp),a
        ld ix,cfgwinbuf1
        xor a
        ld bc,50
        ld de,9999
        call clcr16
        jr c,cfgoky1
        ld (cfgdatwps),hl
cfgoky1 ld ix,cfgwinbuf2
        xor a
        ld bc,1
        ld de,99
        call clcr16
        jr c,cfgoky1
        ld a,l
        ld (cfgdattab),a
cfgoky2 ld a,(fntselobj+12)
        ld hl,cfgdatfnt
        cp (hl)
        push af
        ld (hl),a
        ld a,(papselobj+12)
        ld (cfgdatpap),a
        ld a,(penselobj+12)
        ld (cfgdatpen),a
        call cfgsav
        call cfgini
        pop af
        ld a,(cfgdatfnt)
        call nz,styfnt0
        ld a,(diawin)
        call SyDesktop_WINCLS
        ld de,256*prgtolrec_fntdrp+255-2
        ld a,(maiwinnum)
        call SyDesktop_WINTOL
        jp prgprz0

;### CFGWRP -> Switch between "wrap at window border" and "no wrap"
cfgwrp  ld a,(cfgdatwrp)
        or a
        ld a,2
        jr z,cfgwrp2
        xor a
cfgwrp2 ld (cfgdatwrp),a
        call cfgwrp0
        call cfgini
        call docrfs
        jp prgprz0
cfgwrp0 ld a,(cfgdatwrp)
        or a
        ld a,3+32
        jr z,cfgwrp1
        ld a,1+32
cfgwrp1 ld (prgwinmen3+2),a
        ret

;### CFGBAR -> Switches the status bar on/off
cfgbar  ld hl,prgwinmen4+2
        ld de,cfgdatsta
        ld a,(hl)               ;modify menu
        xor 2
        ld (hl),a
        and 2
        rra
        ld (de),a
        call cfgbar1
        ld de,10
        jr z,cfgbar2
        call edtchg5
        ld de,-10
cfgbar2 ld hl,(prgwindat+10)
        add hl,de
        ld (prgwindat+10),hl
        ld a,(prgwindat)
        cp 2
        ld a,(maiwinnum)
        push af
        call z,SyDesktop_WINMAX
        pop af
        call nz,SyDesktop_WINMID
        jp prgprz0
cfgbar1 ld hl,prgwindat+1
        res 6,(hl)
        ret z
        set 6,(hl)
        ret


;==============================================================================
;### FILE-ROUTINES ############################################################
;==============================================================================

;### FILMOD -> Ask for file-saving, if text has been modified
;### Output     CF=0 ok, CF=1 cancel
filmod  ld a,(txtmulobj+texdatflg)
        rla
        ret nc
        ld hl,prgtxtsav
        ld b,8*4+3+64
        call prginf0
        cp 1
        ret c
        sub 4
        ret z
        ccf
        ret c
        jp filsav0

;### FILNEW -> New file
filnew  call filmod
        jp c,prgprz0
        call docnew
        call docrfs
        jp prgprz0

;### FILOPN -> Open file
filopn  call filmod
        jp c,prgprz0
        xor a
        call filopn0
        or a
        call z,fillod
        jp prgprz0
filopn0 ld hl,App_BnkNum
        add (hl)
        ld hl,docmsk
        ld c,8
        ld ix,100
        ld iy,5000
        ld de,prgwindat
        jp SySystem_SELOPN

;### FILSAS -> Save file as
filsas  call filsav1
        call filtit
        jp prgprz0

;### FILSAV -> Save file
filsav  call filsav0
        jp prgprz0
;-> CF=1 cancel
filsav0 ld a,(docpth)
        or a
        jr nz,filsav2
filsav1 ld a,64
        call filopn0
        or a
        scf
        ret nz
filsav2 call filsto
        or a
        ret

;### FILLOD -> load selected textfile
fillode dw prgtxterr1,prgtxterr2,prgtxterr3,prgtxterr4

fillod  ld hl,docpth
        ld a,(App_BnkNum)
        db #dd:ld h,a
        call SyFile_FILOPN           ;open file
        ld e,2      ;2=error while loading file
        jr c,fillod5
        push af
        ld hl,txtbufmem
        ld bc,txtbufmax
        add hl,bc
        ld (hl),0
        sbc hl,bc
        ld de,(App_BnkNum)
        call SyFile_FILINP           ;load textdata
        pop de
        push bc
        push af
        ld a,d
        call SyFile_FILCLO           ;close file
        pop af
        pop bc
        ld e,2      ;2=error while loading file
        jr c,fillod3
        ld hl,txtbufmem
        add hl,bc
        ld e,0      ;0=ok
        ld (hl),e
        jr nz,fillod1
        inc e       ;1=memory full (only the first part of the file has been loaded)
fillod1 push de         ;loading ok -> init text
        call docini
        call filtit
        jr fillod4
fillod3 push de         ;error while loading -> clear text
        call docnew
fillod4 call docrfs
        pop de
fillod5 inc e:dec e
        ret z
        ld l,e          ;show error message
        ld h,0
        add hl,hl
        ld bc,fillode-2
        add hl,bc
        ld a,(hl)
        inc hl
        ld h,(hl)
        ld l,a
        ld b,1+64
        call prginf0
        jp prgprz0

;### FILSTO -> save actual textfile
filsto  ld hl,txtmulobj+texdatflg   ;reset modified-bit
        res 7,(hl)
        ld hl,docpth
        ld a,(App_BnkNum)
        db #dd:ld h,a
        xor a
        call SyFile_FILNEW           ;create file
        ld e,3      ;3=error while writing file
        jr c,fillod5
        push af
        ld hl,txtbufmem
        ld bc,(txtmulobj+texdatlen)
        add hl,bc
        ld (hl),26
        push hl
        sbc hl,bc
        inc bc
        ld de,(App_BnkNum)
        call SyFile_FILOUT           ;save textdata
        pop hl
        ld (hl),0
        pop de
        push af
        ld a,d
        call SyFile_FILCLO           ;close file
        pop af
        ld e,3      ;3=error while writing file
        jr c,fillod5
        inc e       ;4=device full (only part of the text has been saved)
        or a
        jr nz,fillod5
        ld e,a      ;0=ok
        jr fillod5

;### FILTIT -> Refreshes window title with filename
filtitt db " - Wordpad",0

filtit  ld hl,docpth
        ld e,l:ld d,h
filtit1 call cfgget5
        inc hl
        jr nz,filtit2
        ld e,l:ld d,h
filtit2 or a
        jr nz,filtit1
        dec hl
        sbc hl,de
        ld a,l
        or a
        ret z
        cp 13
        jr c,filtit3
        ld a,12
filtit3 ld c,a
        ld b,0
        ex de,hl
        ld de,prgwintit
        ldir
        ld hl,filtitt
        ld bc,11
        ldir
        ld a,(maiwinnum)
        jp SyDesktop_WINTIT

;### FILPRT -> prints file
filprtfnt   db 0
filprtcod   db 27,"B",27,"b"
            db 27,"I",27,"i"
            db 27,"U",27,"u"

filprtpth1  db "printd\wdpd"
filprtpth2  db "####.job",0
filprtpth3
filprtpth   ds 32+filprtpth3-filprtpth1
filprthnd   db 0

filprt  ld de,256*32+5          ;get system path
        ld ix,filprtpths
        ld iy,0
        ld hl,jmp_sysinf:rst #28
        ld a,r                  ;create random filename
        and 63
        call clcdez
        ld (filprtpth2+0),hl
        rst #20:dw jmp_timget
        call clcdez
        ld (filprtpth2+2),hl
        ld hl,filprtpths        ;build complete printd-path
        ld de,filprtpth
filprt6 ld a,(hl)
        ldi
        or a
        jr nz,filprt6
        dec de
        ld hl,filprtpth1
        ld bc,filprtpth3-filprtpth1
        ldir

        ld hl,filprtpth         ;open job file
        ld a,(App_BnkNum)
        db #dd:ld h,a
        xor a
        call SyFile_FILNEW
        ld hl,prgtxterr5
        ld b,1+8+64
        jp c,prginf1
        ld (filprthnd),a

        ld de,winprtdat
        ld a,#81
        ld (de),a
        ld a,(App_BnkNum)
        call SyDesktop_WINOPN   ;open "printing..." window
        jr c,filprt8
        ld (tmpwin),a

filprt8 ld hl,txtbufmem
        xor a
        ld (filprtfnt),a

filprt1 ld de,prtbufmem
        ld ix,prtbuflen

filprt2 ld a,(hl)
        or a
        jr z,filprt4
        push hl
        ld hl,(cfgdatfnt)
        dec l
        jr nz,filprt5
        push af
        call stychr         ;a=char -> a=type
        ld hl,filprtfnt
        cp (hl)
        jr z,filprt3
        push af
        ld a,(hl)
        ld c,2
        call prtcod         ;cancel old style
        pop af
        ld (filprtfnt),a
        ld c,0
        call prtcod         ;activate new style
filprt3 pop af
        call sty2as

filprt5 ld (de),a
        inc de
        pop hl
        inc hl
        dec ix
        ld a,ixl:or ixh
        jr nz,filprt2
        push hl
        call filprt0
        pop hl
        ;...CF=1 -> error, finished
        jr filprt1

filprt4 call filprt0        ;print last part to file and close
        ld a,(filprthnd)
        call SyFile_FILCLO

        ld a,(tmpwin)
        cp -1
        call nz,SyDesktop_WINCLS   ;close "printing..." window
        ld a,-1
        ld (tmpwin),a

        jp prgprz0

filprt0 ex de,hl            ;print part to file (de=buf pos)
        ld de,prtbufmem
        or a
        sbc hl,de
        ret z
        ld c,l:ld b,h
        ld hl,prtbufmem
        ld de,(App_BnkNum)
        ld a,(filprthnd)
        jp SyFile_FILOUT

prtcod  sub 1
        ret c
        add a:add a
        add c
        ld b,0
        ld c,a
        ld hl,filprtcod
        add hl,bc
        ld bc,2
        ldir
        ret


;==============================================================================
;### EDIT-ROUTINES ############################################################
;==============================================================================

;### EDTCHG -> Editor changed
edtchgf db 0    ;flag, if changed

edtchg  ld a,1                  ;** Set Change-Flag
        ld (edtchgf),a
        jp prgprz0

edtchg0 ld hl,edtchgf           ;** Update only on change
        bit 0,(hl)
        ld (hl),0
        ret z
edtchg1 ld a,(prgwindat+1)      ;** Update only on view
        bit 6,a
        ret z
        call stycur             ;check if char under cursor with a different fontstyle
        call edtchg5
        ld a,(maiwinnum)
        jp SyDesktop_WINSTA
edtchg5 ld a,248                ;** Update content
        rst #20:dw jmp_keyput
        rst #30
        ld iy,prgwinsta
        ld hl,(edtchgm_poi+1)
        ld ix,(txtmulobj+texdatmsg+2)
        inc ix
        call edtchg4
        ld ix,(txtmulobj+texdatmsg+0)
        inc ix
        call edtchg4
        ld ix,(txtmulobj+texdatlen)
        call edtchg4
        ld de,(txtmulobj+texdatmrk)
        ld a,e:or d
        jr z,edtchg3
        bit 7,d
        jr z,edtchg2
        ld a,e:cpl:ld e,a
        ld a,d:cpl:ld d,a
        inc de
edtchg2 push de:pop ix
        call edtchg4
edtchg3 ld (iy-2),0
        ret
edtchg4 push iy:pop de          ;add value
        ld bc,4
        add iy,bc
        ldir
        ld e,5
        push hl
        call clcnum
        pop hl
        inc iy:inc iy:inc iy
        ld (iy-2),","
        ld (iy-1)," "
        ret

;### EDTCUT -> Edit Cut
edtcut  ld a,"X"-64
edtcut0 rst #20:dw jmp_keyput
        jp prgprz0

;### EDTCOP -> Edit Copy
edtcop  ld a,"C"-64
        jr edtcut0

;### EDTPAS -> Edit Paste
edtpas  ld a,"V"-64
        jr edtcut0

;### EDTSAL -> Edit Select All
edtsal  ld a,"A"-64
        jr edtcut0

;### EDTDEL -> Edit Delete
edtdel  ld a,8
        jr edtcut0

;### EDTGOT -> Edit Goto
edtgot  ld hl,(gotdatoln+texdatlen)
        ld (gotdatoln+texdatmrk),hl
        ld hl,0
        ld (gotdatoln+texdatpos),hl
        ld a,3
        ld (gotwingrp+14),a
        ld de,gotwindat
        jp cfgopn0

;### EDTTIM -> Edit Date/Time
edttims db "00:00:00 00.00.0000",0
edttim  ld hl,(txtmulobj+texdatmrk)
        ld a,l:or h
        jr z,edttim1
        ld a,8
        rst #20:dw jmp_keyput
        rst #30
edttim1 ld hl,(txtmulobj+texdatlen)     ;increase length
        ld de,19
        add hl,de
        ex de,hl
        ld hl,(txtmulobj+texdatmax)
        sbc hl,de
        jp c,fndral3
        ld (txtmulobj+texdatlen),de
        ld hl,txtmulobj+texdatflg
        set 7,(hl)
        ld hl,(txtmulobj+texdatpos)     ;insert data
        push hl
        push de
        ex de,hl
        sbc hl,de
        ld c,l:ld b,h
        inc bc
        pop de
        ld hl,txtbufmem
        add hl,de
        ex de,hl
        ld hl,-19
        add hl,de
        lddr
        inc de
        push de
        rst #20:dw #810c                ;generate time/date string
        push hl
        push de
        push bc
        call clcdez:ld (edttims+6),hl
        pop bc:push bc
        ld a,c
        call clcdez:ld (edttims+0),hl
        pop af
        call clcdez:ld (edttims+3),hl
        pop de:push de
        ld a,e
        call clcdez:ld (edttims+12),hl
        pop af
        call clcdez:ld (edttims+9),hl
        pop ix
        ld iy,edttims+15
        ld e,4
        call clcnum
        pop de
        ld hl,edttims                   ;copy time/date string
        ld bc,19
        push bc
        ldir
        pop bc
        pop hl
        add hl,bc
        ld (txtmulobj+texdatmsg+0),hl   ;update display
        ld hl,0
        ld (txtmulobj+texdatmrk),hl
        ld a,249
        rst #20:dw jmp_keyput
        jp prgprz0


;==============================================================================
;### FIND- AND REPLACE-ROUTINES ###############################################
;==============================================================================

;### FNDFND -> Opens Find-Dialogue
fndfnd  call fndfnd1
        ld de,fndwindat
        jp cfgopn0
fndfnd1 ld bc,(txtmulobj+texdatmrk)
        ld a,c:or b
        jr z,fndfnd5
        ld hl,(txtmulobj+texdatpos)
        bit 7,b
        jr z,fndfnd2
        add hl,bc
        ld a,c:cpl:ld c,a
        ld a,b:cpl:ld b,a
        inc bc
fndfnd2 ld a,b
        or a
        jr nz,fndfnd3
        ld a,c
        cp 32+1
        jr c,fndfnd4
fndfnd3 ld bc,32
fndfnd4 ld (fnddatofn+texdatlen),bc
        ld de,txtbufmem
        add hl,de
        ld de,fnddattfn
        ldir
        xor a
        ld (de),a
fndfnd5 ld hl,(fnddatofn+texdatlen)
        ld (fnddatofn+texdatmrk),hl
        ld hl,0
        ld (fnddatofn+texdatpos),hl
        ld a,3
        ld (fndwingrp+14),a
        ld (repwingrp+14),a
        ld hl,fnddattfn
        jp fndlfp

;### FNDREP -> Opens Replace-Dialogue
fndrep  call fndfnd1
        ld hl,fnddattrp
        call fndlfp
        ld de,repwindat
        jp cfgopn0

;### FNDFOK -> Start Find
fndfok  ld a,(diawin)
        call SyDesktop_WINCLS
        jp fndfnx

;### FNDROK -> Start Replace
fndrok  call fndrok0
        ld hl,(txtmulobj+texdatpos)
        call fndsea
        jp c,fndfnx0
fndrok1 call fndfnx2
        rst #30
        ld de,rplwindat
        jp cfgopn0
fndrok0 ld a,(diawin)
        call SyDesktop_WINCLS
        ld hl,fnddattfn
        call fndplf
        ld hl,fnddattrp
        call fndplf
        rst #30         ;let the desktop-manager close the window first, before the text is modified
        ret

;### FNDRDR -> Replace-Dialogue -> Replace
fndrdr  call fndrok0
        ld hl,(txtmulobj+texdatpos)
        ld de,(txtmulobj+texdatmrk)
        add hl,de
        push hl
        call fndrpl
        pop de
        jr c,fndral3
        ld hl,(fnddatorp+texdatlen)
        add hl,de
        ld (txtmulobj+texdatmsg+0),hl
        push hl
        ld hl,0
        ld (txtmulobj+texdatmrk),hl
        ld a,249
        rst #20:dw jmp_keyput
        rst #30
        pop hl
        call fndsea
        jr nc,fndrok1
        jp prgprz0

;### FNDRDA -> Replace-Dialogue -> Replace All
fndrda  ld hl,(txtmulobj+texdatpos)
        ld de,(txtmulobj+texdatmrk)
        add hl,de
        ld (txtmulobj+texdatpos),hl
        ld hl,0
        ld (txtmulobj+texdatmrk),hl
        jr fndral

;### FNDRAL -> Start Replace all
fndral  call fndrok0
        ld bc,0
        ld a,(fnddatall)
        dec a
        ld l,a:ld h,a
        jr z,fndral1
fndral0 ld hl,(txtmulobj+texdatpos)
fndral1 push bc
        call fndsea
        jr c,fndral2
        push hl
        call fndrpl
        pop hl
        pop bc
        jr c,fndral3
        inc bc
        ld de,(fnddatorp+texdatlen)
        add hl,de
        jr fndral1
fndral2 pop bc
        ld a,c:or b
        jr z,fndfnx0
        push bc:pop ix
        ld e,5
        ld iy,fndmsgtxt2b
        call clcnum
        push iy:pop de
        inc de
        ld hl,fndmsgtxt2c
        ld bc,8
        ldir
        call docrfs
        ld hl,prgtxtrep
        ld b,8*2+1+64+128
        jp prginf1
fndral3 ld hl,prgtxtmem
        ld b,8*3+1+64
        jp prginf1

;### FNDFNX -> Find next
fndfnx  ld hl,fnddattfn
        call fndplf
        ld hl,(txtmulobj+texdatpos)
        call fndsea
        jr nc,fndfnx1
fndfnx0 ld hl,prgtxtfnd
        ld b,8*2+1+64
        jp prginf1
fndfnx1 call fndfnx2
        jp prgprz0
fndfnx2 ld de,(fnddatofn+texdatlen)
        add hl,de
        ld (txtmulobj+texdatmsg+0),hl
        ld a,e:cpl:ld e,a
        ld a,d:cpl:ld d,a
        inc de
        ld (txtmulobj+texdatmsg+2),de
        ld a,250
        rst #20:dw jmp_keyput
        ret

;### FNDRPL -> Replaces text
;### Input      HL=Offset, (fnddatofn+texdatlen)=old length, fnddattrp=new text, (fnddatorp+texdatlen)=new length
;### Output     CF=0 ok, CF=1 memory full
fndrplo dw 0    ;offset
fndrpl  push hl
        ex de,hl
        ld hl,(fnddatofn+texdatlen)
        ld bc,(fnddatorp+texdatlen)
        or a
        sbc hl,bc
        push hl
        ld c,l:ld b,h
        ld hl,(txtmulobj+texdatlen)
        or a
        sbc hl,bc       ;hl=new length
        push hl
        ld bc,txtbufmax
        scf
        sbc hl,bc
        ccf
        pop hl
        pop bc          ;bc=lendif
        ret c           ;new length >= max+1 -> memory full
        ld (txtmulobj+texdatlen),hl
        ld a,c:or b
        jr z,fndrpl2
        push bc
        push hl
        ld a,b
        sbc hl,de
        ld bc,(fnddatorp+texdatlen)
        sbc hl,bc
        ld c,l:ld b,h
        inc bc          ;bc=copylength (newlen-new wordlength-offset+1)
        pop hl          ;hl=newlen
        rla
        jr nc,fndrpl1
        ld de,txtbufmem ;expand text -> copy backwards
        add hl,de       ;hl=last char+1
        pop de          ;de=dif
        push hl
        add hl,de       ;hl=last char+dif = source
        pop de          ;de=last char = destination
        lddr
        jr fndrpl2
fndrpl1 ld hl,(fnddatorp+texdatlen)
        add hl,de
        ld de,txtbufmem
        add hl,de
        ex de,hl        ;de=offset + new wordlength=destination
        pop hl
        add hl,de       ;hl=destination + dif=source
        ldir
fndrpl2 pop de
        ld hl,txtbufmem
        add hl,de
        ex de,hl
        ld hl,fnddattrp
        ld bc,(fnddatorp+texdatlen)
        ldir
        ld hl,txtmulobj+texdatflg
        set 7,(hl)      ;modified
        or a
        ret

;### FNDSEA -> Searches for text
;### Input      HL=Startoffset, fnddattfn=Text, (fnddatofn+texdatlen)=length, (fnddatcas)=Flag, if case sensitive
;### Output     CF=0 ok (HL=offset), CF=1 nothing found
fndsea  ld de,(fnddatofn+texdatlen)
        ld a,e:or d
        scf
        ret z
        push hl
        add hl,de
        ex de,hl
        ld hl,(txtmulobj+texdatlen)
        scf
        sbc hl,de
        ld c,l:ld b,h
        pop hl
        ret c
        inc bc              ;bc=len
        ld de,txtbufmem
        add hl,de           ;hl=adr
        ld a,(fnddattfn)
        call fndcas
        ld e,a
fndsea1 ld a,(hl)       ;search for 1st char
        call fndcas
        cp e
        jr z,fndsea3
fndsea2 inc hl          ;next char
        dec bc
        ld a,c:or b
        jr nz,fndsea1
        scf
        ret
fndsea3 dec hl          ;1st char found
        ld a,(hl)
        inc hl
        call fndaln
        jr c,fndsea2
        push bc
        push de
        push hl
        ld bc,(fnddatofn+texdatlen)
        ld de,fnddattfn
fndsea4 inc hl          ;check remaining chars
        dec c
        jr z,fndsea6
        inc de
        ld a,(de)
        call fndcas
        ld b,a
        ld a,(hl)
        call fndcas
        cp b
        jr z,fndsea4
fndsea5 pop hl          ;not found, next char
        pop de
        pop bc
        jr fndsea2
fndsea6 ld a,(hl)       ;complete string found
        call fndaln
        jr c,fndsea5
        pop hl
        pop de
        pop bc
        ld de,txtbufmem
        or a
        sbc hl,de
        ret

;### FNDCAS -> Converts char into lcase, if case-flag is not set
;### Input      A=Char
;### Output     A=Char
;### Destroyed  F
fndcas  push hl
        ld hl,fnddatcas
        bit 0,(hl)
        pop hl
        ret nz
        cp "A"
        ret c
        cp "Z"+1
        ret nc
        add "a"-"A"
        ret

;### FNDALN -> Checks, if word only + char is alphanumeric
;### Input      A=Char
;### Output     CF=1 word only + char is alphanumeric
;### Destroyed  F
fndaln  or a
        push hl
        ld hl,fnddatwrd
        bit 0,(hl)
        pop hl
        ret z
        cp "_"
        scf
        ret z
        cp "0"
        ccf
        ret nc
        cp "9"+1
        ret c
        cp "A"
        ccf
        ret nc
        cp "Z"+1
        ret c
        cp "a"
        ccf
        ret nc
        cp "z"+1
        ret

;### FNDPLF -> Converts ^P into 13+10
;### Input      HL=String
;### Destroyed  AF,BC,DE,HL
fndplf  ld bc,13*256+10
        ld de,"^"*256+"P"
        jr fndlfp0

;### FNDLFP -> Converts 13+10 into ^P
;### Input      HL=String
;### Destroyed  AF,BC,DE,HL
fndlfp  ld de,13*256+10
        ld bc,"^"*256+"P"
fndlfp0 ld a,(hl)
fndlfp1 or a
        ret z
        inc hl
        cp d
        jr nz,fndlfp0
        ld a,(hl)
        cp e
        jr nz,fndlfp1
        dec hl
        ld (hl),b
        inc hl
        ld (hl),c
        inc hl
        jr fndlfp0

;### FNDGOT -> Goto
fndgot  ld a,(diawin)           ;close dialogue
        call SyDesktop_WINCLS
        ld ix,gotdattln         ;convert line
        xor a
        ld bc,1
        ld de,9999
        call clcr16
        jr nc,fndgot2
fndgot1 ld hl,prgtxtnum
        ld b,8*3+1+64
        jp prginf1
fndgot2 push hl
        ld ix,gotdattcl         ;convert column
        xor a
        ld bc,1
        ld de,16383
        call clcr16
        pop bc
        jr c,fndgot1
        push hl                 ;limit max-line
        ld hl,(txtmulobj+texdatlnt)
        sbc hl,bc
        jr nc,fndgot3
        add hl,bc
        ld c,l:ld b,h
fndgot3 ld ix,txtmulobj+texdatlln
        ld hl,0                 ;goto line
fndgot4 dec bc
        ld a,c:or b
        jr z,fndgot5
        ld e,(ix+0)
        ld d,(ix+1)
        res 7,d
        add hl,de
        inc ix
        inc ix
        jr fndgot4
fndgot5 ex de,hl
        pop hl                  ;limit max-column
        ld c,(ix+0)
        ld b,(ix+1)
        inc bc
        bit 7,b
        res 7,b
        jr z,fndgot6
        dec bc:dec bc
fndgot6 sbc hl,bc
        jr nc,fndgot7
        add hl,bc
        ld c,l:ld b,h
fndgot7 dec bc
        ex de,hl
        add hl,bc
        ld (txtmulobj+texdatmsg+0),hl
        ld hl,0
        ld (txtmulobj+texdatmsg+2),hl
        ld a,250
        rst #20:dw jmp_keyput   ;set cursor
        jp prgprz0


;==============================================================================
;### DOCUMENT-ROUTINES ########################################################
;==============================================================================

texdatadr       equ 0           ;Zeiger auf Text
texdatbeg       equ 2           ;erstes angezeigtes Zeichen (nur singleline)
texdatpos       equ 4           ;Cursorposition im Gesamttext
texdatmrk       equ 6           ;0/Anzahl markierter Zeichen [neg->Cursor=Ende Markierung]
texdatlen       equ 8           ;Textlänge
texdatmax       equ 10          ;maximal zulässige Textlänge (1-16383; exklusive 0-Terminator)
texdatflg       equ 12          ;Flags (Bit0=Paßwort [nur singleline], Bit1=ReadOnly, Bit2=AltColor, Bit3=AltFont [nur multiline], Bit4=keymapping, Bit7=modified)
;** extended 16c/altfont
texdatcol       equ 13          ;4bit txtpap, 4bit txtpen
texdatrhm       equ 14          ;4bit rahmen1, 4bit rahmen2
texdatfnt       equ 15          ;Adresse des alternativen Fonts
texdatrs1       equ 17          ;*reserved 1byte*
;** ab hier nur Multiline
texdatlnt       equ 18          ;aktuelle Anzahl Zeilen
texdatxmx       equ 20          ;maximale Zeilenbreite in Pixeln bei Wordwrap-Pos-Vorgabe (-1=unbegrenzt)
texdatymx       equ 22          ;maximale Anzahl Zeilen (*2 bytes ab texdatlln!)
texdatxwn       equ 24          ;win x len ohne slider für bisherige formatierung (winx<>aktx -> Neuformatierung notwendig, durch -8 erzwingen)
texdatywn       equ 26          ;win y len ohne slider

texdatzgr       equ 28          ;pointer auf diesen datensatz (ab texdatadr)
texdatxfl       equ 30          ;full x len (=Länge der längsten Textzeile in Pixel)
texdatyfl       equ 32          ;full y len (=Anzahl aller Textzeilen * 8)
texdatxof       equ 34          ;offset x   (=texdatbeg)
texdatyof       equ 36          ;offset y
texdatfg2       equ 38          ;Flags (Bit0=WordWrap-Position vorgegeben [dann Xslider], Bit1=1)
texdattab       equ 39          ;Tabstop Größe (1-255; 0=kein Tabstop) ##!!##

texdatmsg       equ 40          ;Message-Buffer (in POS, MRK, out CXP, CYP)
texdatrs2       equ 44          ;*reserved 4byte*
texdatkmp       equ 46          ;keymap
texdatlln       equ 48          ;Zeilen-Längentabelle (bit15=cr+lf am ende vorhanden)

;### DOCINI -> initialise loaded document
docini  ld hl,txtmulobj+texdatflg   ;reset modified-bit
        res 7,(hl)
        ld hl,txtbufmem             ;search for EOF (0 or 26 [CPC])
        ld bc,txtbufmax
        push hl
        xor a                       ;search for 0
        cpir
        ex (sp),hl
        ld bc,txtbufmax
        ld a,26                     ;search for 26 (EOF)
        cpir
        pop de
        or a
        sbc hl,de
        jr nc,docini1
        add hl,de
        ex de,hl
docini1 ex de,hl
        dec hl
        xor a
        ld (hl),a
        ld bc,txtbufmem
        sbc hl,bc                   ;hl=textlength (=min(found(0),found(26))
        ld (txtmulobj+texdatlen),hl
docini2 ld a,l
        or h
        jr z,docnew1
        ld a,(bc)
        cp 10
        jr z,docini4
        cp 13
        jr z,docini4
        cp 32
        jr c,docini3
        cp 128
        jr c,docini4
docini3 ld a,"?"
        ld (bc),a
docini4 inc bc
        dec hl
        jr docini2

;### DOCNEW -> clears and initialise document
docnew  ld hl,txtmulobj+texdatflg   ;reset modified-bit
        res 7,(hl)
        xor a
        ld (txtbufmem),a
        ld l,a:ld h,a
        ld (txtmulobj+texdatlen),hl
docnew1 ld (txtmulobj+texdatpos),hl
        ld (txtmulobj+texdatmrk),hl
        ld (txtmulobj+texdatxof),hl
        ld (txtmulobj+texdatyof),hl
        ret

;### DOCRFS -> refresh document display
docrfs  call edtchg1
        ld hl,-8
        ld (txtmulobj+texdatxwn),hl
        ld a,(maiwinnum)
        ld e,1
        jp SyDesktop_WINDIN


prtbuflen   equ 2048
prtbufmem   db 0
;!!!last label in code-area!!!


;==============================================================================
;### DATA AREA ################################################################
;==============================================================================

App_BegData

txtbufmem db 0
;!!!last label in data-area!!!

;==============================================================================
;### TRANSFER AREA ############################################################
;==============================================================================

App_BegTrns

prgicn16c db 12,24,24:dw $+7:dw $+4,12*24:db 5
db #88,#88,#88,#88,#88,#88,#88,#88,#88,#88,#88,#88,#88,#81,#18,#11,#81,#18,#11,#81,#18,#18,#88,#88,#88,#d8,#dd,#8d,#d8,#dd,#8d,#d8,#dd,#8d,#18,#88,#8d,#81,#88,#18,#81,#88,#18,#81,#88,#d1,#d1,#88
db #8d,#81,#88,#18,#81,#88,#18,#81,#88,#d1,#d1,#88,#8d,#88,#88,#88,#88,#88,#88,#88,#88,#d1,#d1,#88,#8d,#88,#88,#88,#88,#88,#88,#88,#88,#d1,#d1,#88,#8d,#85,#55,#55,#55,#55,#55,#55,#88,#d1,#d1,#88
db #8d,#88,#88,#88,#88,#88,#88,#88,#88,#d1,#d1,#88,#8d,#85,#55,#55,#55,#55,#55,#55,#88,#d1,#d1,#88,#8d,#88,#88,#88,#88,#88,#88,#88,#88,#d1,#d1,#88,#8d,#85,#55,#55,#55,#55,#58,#8f,#88,#d1,#d1,#88
db #8d,#88,#88,#88,#88,#88,#88,#ff,#d8,#d1,#d1,#88,#8d,#85,#55,#55,#55,#58,#8f,#df,#d8,#d1,#d1,#88,#8d,#88,#88,#88,#88,#88,#fd,#8f,#d8,#d1,#d1,#88,#8d,#85,#55,#55,#58,#8f,#d8,#8f,#d8,#d1,#d1,#88
db #8d,#88,#88,#88,#88,#ff,#ff,#ff,#d8,#d1,#d1,#88,#8d,#85,#55,#58,#8f,#dd,#dd,#df,#d8,#d1,#d1,#88,#8d,#88,#88,#88,#fd,#88,#88,#8f,#d8,#d1,#d1,#88,#8d,#85,#55,#8f,#ff,#88,#88,#ff,#f8,#d1,#d1,#88
db #8d,#88,#88,#88,#dd,#d8,#88,#dd,#dd,#d1,#d1,#88,#8d,#88,#88,#88,#88,#88,#88,#88,#88,#d1,#d1,#88,#88,#dd,#dd,#dd,#dd,#dd,#dd,#dd,#dd,#1d,#18,#88,#88,#81,#11,#11,#11,#11,#11,#11,#11,#11,#88,#88

;### PRGPRZS -> Stack for application process
        ds 128
prgstk  ds 6*2
        dw prgprz
App_PrcID db 0
App_MsgBuf ds 14

;### TOOLBAR ICON BITMAPS #####################################################

gfxtola db 8,16,14:dw $+7:dw $+4,8*14:db 5      ;new
db #68,#88,#88,#88,#88,#88,#88,#88, #68,#66,#66,#66,#66,#66,#66,#67, #68,#66,#11,#11,#11,#66,#66,#67, #68,#66,#18,#88,#81,#16,#66,#67, #68,#66,#18,#88,#81,#81,#66,#67, #68,#66,#18,#88,#81,#11,#16,#67, #68,#66,#18,#88,#88,#88,#16,#67
db #68,#66,#18,#88,#88,#88,#16,#67, #68,#66,#18,#88,#88,#88,#16,#67, #68,#66,#18,#88,#88,#88,#16,#67, #68,#66,#18,#88,#88,#88,#16,#67, #68,#66,#11,#11,#11,#11,#16,#67, #68,#66,#66,#66,#66,#66,#66,#67, #68,#77,#77,#77,#77,#77,#77,#77
gfxtolb db 8,16,14:dw $+7:dw $+4,8*14:db 5      ;open
db #68,#88,#88,#88,#88,#88,#88,#88, #68,#66,#66,#66,#61,#16,#66,#67, #68,#66,#66,#66,#16,#61,#61,#67, #68,#66,#11,#16,#66,#66,#11,#67, #68,#61,#00,#01,#11,#61,#11,#67, #68,#61,#00,#00,#01,#66,#66,#67, #68,#61,#00,#00,#11,#11,#11,#17
db #68,#61,#00,#01,#22,#22,#21,#67, #68,#61,#00,#12,#22,#22,#16,#67, #68,#61,#01,#22,#22,#21,#66,#67, #68,#61,#12,#22,#22,#16,#66,#67, #68,#61,#11,#11,#11,#66,#66,#67, #68,#66,#66,#66,#66,#66,#66,#67, #68,#77,#77,#77,#77,#77,#77,#77
gfxtolc db 8,16,14:dw $+7:dw $+4,8*14:db 5      ;save
db #68,#88,#88,#88,#88,#88,#88,#88, #68,#66,#66,#66,#66,#66,#66,#67, #68,#61,#11,#11,#11,#11,#11,#67, #68,#61,#F1,#00,#00,#01,#01,#67, #68,#61,#F1,#00,#00,#01,#11,#67, #68,#61,#F1,#00,#00,#01,#F1,#67, #68,#61,#FF,#11,#11,#1F,#F1,#67
db #68,#61,#FF,#FF,#FF,#FF,#F1,#67, #68,#61,#FF,#11,#11,#11,#F1,#67, #68,#61,#FF,#11,#11,#01,#F1,#67, #68,#61,#FF,#11,#11,#01,#F1,#67, #68,#66,#11,#11,#11,#11,#11,#67, #68,#66,#66,#66,#66,#66,#66,#67, #68,#77,#77,#77,#77,#77,#77,#77
gfxtold db 8,16,14:dw $+7,$+4,16*14:db 5        ;print
db #68,#88,#88,#88,#88,#88,#88,#88, #68,#66,#66,#66,#66,#66,#66,#67, #68,#66,#66,#61,#11,#11,#11,#67, #68,#66,#66,#61,#88,#88,#81,#67, #68,#66,#66,#18,#11,#18,#16,#67, #68,#66,#66,#18,#88,#88,#16,#67, #68,#66,#61,#81,#11,#81,#66,#67
db #68,#66,#11,#11,#11,#11,#16,#67, #68,#61,#aa,#aa,#aa,#aa,#a1,#67, #68,#61,#ad,#dd,#af,#fa,#a1,#67, #68,#61,#aa,#aa,#aa,#aa,#a1,#67, #68,#66,#11,#11,#11,#11,#16,#67, #68,#66,#66,#66,#66,#66,#66,#67, #68,#77,#77,#77,#77,#77,#77,#77

gfxtole db 8,16,14:dw $+7:dw $+4,8*14:db 5      ;bold
db #68,#88,#88,#88,#88,#88,#88,#88, #68,#66,#66,#66,#66,#66,#66,#67, #68,#66,#66,#66,#66,#66,#66,#67, #68,#66,#11,#11,#11,#11,#66,#67, #68,#66,#61,#11,#66,#11,#16,#67, #68,#66,#61,#11,#66,#11,#16,#67, #68,#66,#61,#11,#66,#11,#16,#67
db #68,#66,#61,#11,#11,#11,#66,#67, #68,#66,#61,#11,#66,#11,#16,#67, #68,#66,#61,#11,#66,#11,#16,#67, #68,#66,#61,#11,#66,#11,#16,#67, #68,#66,#11,#11,#11,#11,#66,#67, #68,#66,#66,#66,#66,#66,#66,#67, #68,#77,#77,#77,#77,#77,#77,#77
gfxtolf db 8,16,14:dw $+7:dw $+4,8*14:db 5      ;italics
db #68,#88,#88,#88,#88,#88,#88,#88, #68,#66,#66,#66,#66,#66,#66,#67, #68,#66,#66,#66,#66,#66,#66,#67, #68,#66,#66,#66,#11,#11,#16,#67, #68,#66,#66,#66,#61,#16,#66,#67, #68,#66,#66,#66,#61,#16,#66,#67, #68,#66,#66,#66,#11,#66,#66,#67
db #68,#66,#66,#66,#11,#66,#66,#67, #68,#66,#66,#61,#16,#66,#66,#67, #68,#66,#66,#61,#16,#66,#66,#67, #68,#66,#66,#11,#66,#66,#66,#67, #68,#66,#11,#11,#11,#66,#66,#67, #68,#66,#66,#66,#66,#66,#66,#67, #68,#77,#77,#77,#77,#77,#77,#77
gfxtolg db 8,16,14:dw $+7:dw $+4,8*14:db 5      ;underlined
db #68,#88,#88,#88,#88,#88,#88,#88, #68,#66,#66,#66,#66,#66,#66,#67, #68,#66,#66,#66,#66,#66,#66,#67, #68,#66,#11,#11,#61,#11,#16,#67, #68,#66,#61,#16,#66,#11,#66,#67, #68,#66,#61,#16,#66,#11,#66,#67, #68,#66,#61,#16,#66,#11,#66,#67
db #68,#66,#61,#16,#66,#11,#66,#67, #68,#66,#61,#16,#66,#11,#66,#67, #68,#66,#66,#11,#11,#16,#66,#67, #68,#66,#66,#66,#66,#66,#66,#67, #68,#66,#11,#11,#11,#11,#16,#67, #68,#66,#66,#66,#66,#66,#66,#67, #68,#77,#77,#77,#77,#77,#77,#77

arrdwngfx db 4,8,8:dw $+7:dw $+4,4*8:db 5
db #11,#11,#11,#11, #18,#88,#88,#81, #18,#81,#18,#81, #11,#11,#11,#11, #18,#11,#11,#81, #18,#81,#18,#81, #18,#88,#88,#81, #11,#11,#11,#11


;### FONT PREVIEW BITMAPS #####################################################

bmpfnttab
dw bmpfntdef,bmpfntwys
dw bmpfntbld,bmpfntita,bmpfntbig,bmpfntmic,bmpfntmsd
dw bmpfntari,bmpfntcou,bmpfntede,bmpfnttim


bmpfntdef0  db 2
bmpfntdef   db 14,28,06:dw $+7:dw $+4,14*06:db 5
db #11,#18,#88,#88,#88,#81,#88,#88,#88,#88,#88,#81,#88,#18
db #18,#81,#88,#11,#88,#18,#88,#11,#18,#18,#81,#81,#88,#11
db #18,#81,#81,#88,#18,#11,#81,#88,#18,#18,#81,#81,#88,#18
db #18,#81,#81,#11,#18,#18,#81,#88,#18,#18,#81,#81,#88,#18
db #18,#81,#81,#88,#88,#18,#81,#88,#18,#18,#81,#81,#88,#18
db #11,#18,#88,#11,#18,#18,#88,#11,#18,#81,#18,#88,#18,#81

bmpfntwys0  db 2
bmpfntwys   db 20,40,06:dw $+7:dw $+4,20*06:db 5
db #11,#88,#11,#81,#18,#81,#18,#81,#11,#18,#18,#81,#88,#81,#81,#88,#81,#88,#11,#18
db #11,#88,#11,#88,#11,#11,#88,#11,#88,#88,#88,#81,#88,#81,#88,#18,#18,#81,#88,#88
db #11,#88,#11,#88,#81,#18,#88,#81,#11,#88,#18,#81,#88,#81,#88,#81,#88,#81,#81,#18
db #11,#11,#11,#88,#81,#18,#88,#88,#81,#18,#18,#18,#18,#18,#88,#18,#88,#18,#81,#88
db #11,#11,#11,#88,#81,#18,#88,#11,#81,#18,#18,#11,#81,#18,#88,#18,#88,#18,#81,#88
db #11,#88,#11,#88,#81,#18,#88,#81,#11,#88,#18,#18,#88,#18,#88,#18,#88,#81,#18,#88

bmpfntbld0  db 2
bmpfntbld   db 12,24,06:dw $+7:dw $+4,12*06:db 5
db #11,#11,#88,#88,#88,#88,#11,#88,#88,#81,#18,#88
db #11,#81,#18,#88,#88,#88,#11,#88,#88,#81,#18,#88
db #11,#11,#88,#81,#11,#88,#11,#88,#81,#11,#18,#88
db #11,#81,#18,#11,#81,#18,#11,#88,#11,#81,#18,#88
db #11,#81,#18,#11,#81,#18,#11,#88,#11,#81,#18,#88
db #11,#11,#88,#81,#11,#88,#81,#18,#81,#11,#18,#88

bmpfntita0  db 2
bmpfntita   db 12,24,06:dw $+7:dw $+4,12*06:db 5
db #81,#88,#18,#88,#88,#88,#88,#18,#81,#88,#88,#88
db #81,#88,#18,#88,#88,#88,#88,#18,#88,#88,#88,#88
db #81,#88,#11,#88,#81,#11,#88,#18,#81,#88,#81,#11
db #18,#81,#88,#81,#18,#18,#81,#88,#18,#81,#18,#88
db #18,#81,#88,#81,#88,#18,#81,#88,#18,#81,#88,#88
db #18,#88,#18,#88,#11,#18,#88,#18,#18,#88,#11,#18

bmpfntbig0  db 0
bmpfntbig   db 10,20,10:dw $+7:dw $+4,10*10:db 5
db #11,#11,#11,#88,#88,#88,#88,#88,#88,#88
db #11,#88,#81,#18,#11,#88,#88,#88,#88,#88
db #11,#88,#81,#18,#88,#88,#88,#88,#88,#88
db #11,#88,#81,#18,#11,#88,#11,#11,#88,#88
db #11,#11,#11,#88,#11,#81,#18,#81,#18,#88
db #11,#88,#81,#18,#11,#81,#18,#81,#18,#88
db #11,#88,#81,#18,#11,#81,#18,#81,#18,#88
db #11,#88,#81,#18,#11,#88,#11,#11,#18,#88
db #11,#11,#11,#88,#11,#88,#88,#81,#18,#88
db #88,#88,#88,#88,#88,#81,#11,#11,#88,#88

bmpfntmic0  db 2
bmpfntmic   db 10,20,05:dw $+7:dw $+4,10*05:db 5
db #18,#18,#81,#88,#88,#88,#88,#88,#88,#88
db #11,#18,#88,#88,#81,#18,#18,#18,#81,#88
db #18,#18,#81,#88,#18,#88,#11,#88,#18,#18
db #18,#18,#81,#88,#18,#88,#18,#88,#18,#18
db #18,#18,#81,#88,#81,#18,#18,#88,#81,#88

bmpfntmsd0  db 1
bmpfntmsd   db 24,48,07:dw $+7:dw $+4,24*07:db 5
db #11,#88,#81,#18,#88,#11,#11,#88,#88,#88,#88,#88,#11,#11,#18,#88,#81,#11,#11,#88,#88,#11,#11,#88
db #11,#18,#11,#18,#81,#18,#81,#18,#88,#88,#88,#88,#81,#18,#11,#88,#11,#88,#81,#18,#81,#18,#81,#18
db #11,#11,#11,#18,#88,#11,#88,#88,#88,#88,#88,#88,#81,#18,#81,#18,#11,#88,#81,#18,#88,#11,#88,#88
db #11,#11,#11,#18,#88,#81,#18,#88,#81,#11,#11,#18,#81,#18,#81,#18,#11,#88,#81,#18,#88,#81,#18,#88
db #11,#81,#81,#18,#88,#88,#11,#88,#88,#88,#88,#88,#81,#18,#81,#18,#11,#88,#81,#18,#88,#88,#11,#88
db #11,#88,#81,#18,#81,#18,#81,#18,#88,#88,#88,#88,#81,#18,#11,#88,#11,#88,#81,#18,#81,#18,#81,#18
db #11,#88,#81,#18,#88,#11,#11,#88,#88,#88,#88,#88,#11,#11,#18,#88,#81,#11,#11,#88,#88,#11,#11,#88

bmpfntari0  db 1
bmpfntari   db 16,32,07:dw $+7:dw $+4,16*07:db 5
db #88,#81,#88,#88,#88,#18,#88,#88,#81,#88,#88,#88,#18,#88,#81,#88
db #88,#18,#18,#88,#88,#88,#88,#88,#81,#88,#88,#81,#18,#88,#11,#88
db #88,#18,#18,#81,#11,#18,#11,#11,#81,#88,#88,#88,#18,#88,#81,#88
db #81,#88,#81,#81,#88,#18,#88,#81,#81,#88,#88,#88,#18,#88,#81,#88
db #81,#11,#11,#81,#88,#18,#81,#11,#81,#88,#88,#88,#18,#88,#81,#88
db #81,#88,#81,#81,#88,#18,#18,#81,#81,#88,#88,#88,#18,#88,#81,#88
db #18,#88,#88,#11,#88,#18,#11,#11,#81,#88,#88,#88,#18,#88,#81,#88

bmpfntcou0  db 2
bmpfntcou   db 18,36,06:dw $+7:dw $+4,18*06:db 5
db #11,#18,#88,#88,#88,#88,#88,#88,#88,#88,#81,#88,#88,#88,#88,#88,#88,#88
db #18,#18,#88,#88,#88,#88,#88,#88,#88,#88,#88,#88,#88,#88,#88,#88,#88,#88
db #18,#88,#88,#11,#81,#18,#11,#81,#11,#18,#11,#88,#81,#11,#88,#11,#11,#88
db #18,#88,#81,#88,#18,#18,#81,#88,#18,#88,#81,#88,#81,#11,#88,#81,#88,#88
db #18,#88,#81,#88,#18,#18,#81,#88,#18,#88,#81,#88,#81,#88,#88,#81,#88,#88
db #81,#18,#88,#11,#88,#81,#11,#81,#11,#88,#11,#18,#88,#11,#88,#11,#18,#88

bmpfntede0  db 0
bmpfntede   db 16,32,09:dw $+7:dw $+4,16*09:db 5
db #11,#11,#88,#88,#18,#88,#88,#88,#88,#88,#88,#88,#88,#88,#18,#81
db #81,#88,#88,#88,#18,#88,#88,#88,#88,#88,#88,#88,#88,#88,#18,#81
db #81,#88,#88,#88,#18,#88,#88,#88,#88,#18,#88,#88,#88,#88,#18,#81
db #81,#88,#88,#11,#18,#88,#11,#11,#88,#11,#11,#88,#88,#88,#18,#81
db #81,#11,#81,#88,#18,#88,#18,#81,#88,#18,#81,#88,#88,#88,#18,#81
db #81,#88,#81,#88,#18,#88,#11,#11,#88,#18,#81,#88,#88,#88,#18,#81
db #81,#88,#81,#88,#18,#88,#18,#88,#88,#18,#81,#88,#88,#88,#18,#81
db #81,#88,#81,#88,#18,#88,#18,#88,#88,#18,#81,#88,#88,#88,#18,#81
db #81,#11,#88,#11,#11,#88,#11,#11,#88,#18,#81,#88,#88,#88,#18,#81

bmpfnttim0  db 1
bmpfnttim   db 18,36,07:dw $+7:dw $+4,18*07:db 5
db #11,#11,#18,#18,#88,#88,#88,#88,#88,#88,#88,#88,#88,#11,#88,#81,#18,#88
db #18,#18,#18,#88,#88,#88,#88,#88,#88,#88,#88,#88,#88,#81,#88,#18,#81,#88
db #88,#18,#81,#18,#11,#11,#18,#88,#18,#88,#11,#88,#88,#81,#88,#88,#81,#88
db #88,#18,#88,#18,#81,#81,#81,#81,#81,#81,#88,#88,#88,#81,#88,#88,#81,#88
db #88,#18,#88,#18,#81,#81,#81,#81,#11,#81,#18,#88,#88,#81,#88,#88,#18,#88
db #88,#18,#88,#18,#81,#81,#81,#81,#88,#88,#81,#88,#88,#81,#88,#81,#81,#88
db #81,#11,#81,#11,#11,#11,#11,#18,#11,#81,#18,#88,#88,#11,#18,#11,#11,#88


;==============================================================================
;%%% MULTI LANGUAGE TEXTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;==============================================================================

texts_int
read"App-Wordpad-texts.asm"
texts_int_end

list
texts_int_len   equ texts_int_end-texts_int
nolist


;### STRINGS ##################################################################

docmsk  db "TXT",0
docpth  ds 256

filprtpths  ds 32

prgwintit   db "untitled - Wordpad",0:ds 12-8
prgwinsta   ds 4*11

prgtxtinf2  db " Version 1.1 (Build "
read "..\..\..\SRC-Main\build.asm"
            db "pdt)"
prgtxtinf0  db 0

;### FIND AND REPLACE #########################################################

fnddattfn   ds 33
fnddattrp   ds 33
gotdattln   db "1":ds 4
gotdattcl   db "1":ds 5

fndmsgtxt2a db "Replaced "
fndmsgtxt2b ds 8+5
fndmsgtxt2c db " times.",0

;### CONFIG ###################################################################

coltxt00    db "00",0
coltxt01    db "01",0
coltxt02    db "02",0
coltxt03    db "03",0
coltxt04    db "04",0
coltxt05    db "05",0
coltxt06    db "06",0
coltxt07    db "07",0
coltxt08    db "08",0
coltxt09    db "09",0
coltxt10    db "10",0
coltxt11    db "11",0
coltxt12    db "12",0
coltxt13    db "13",0
coltxt14    db "14",0
coltxt15    db "15",0

;### MENU #####################################################################

menicn_null         db 4,8,1:dw $+7,$+4,4:db 5: db #66,#66,#66,#66

prgwinmen1tx1 db 6,128,-1:dw menicn_filenew+1:      db 7:dw prgwinmen1tx1_poi:db 0
prgwinmen1tx2 db 6,128,-1:dw menicn_fileopen+1:     db 7:dw prgwinmen1tx2_poi:db 0
prgwinmen1tx3 db 6,128,-1:dw menicn_filesave+1:     db 7:dw prgwinmen1tx3_poi:db 0
prgwinmen1tx4 db 6,128,-1:dw menicn_filesaveas+1:   db 7:dw prgwinmen1tx4_poi:db 0
prgwinmen1tx5 db 6,128,-1:dw menicn_print+1:        db 7:dw prgwinmen1tx5_poi:db 0
prgwinmen1tx6 db 6,128,-1:dw menicn_quit+1:         db 7:dw prgwinmen1tx6_poi:db 0

menicn_filenew      db 4,8,7:dw $+7,$+4,28:db 5: db #61,#11,#11,#66, #61,#88,#81,#16, #61,#88,#88,#16, #61,#88,#88,#16, #61,#88,#88,#16, #61,#88,#88,#16, #61,#11,#11,#16
menicn_fileopen     db 4,8,7:dw $+7,$+4,28:db 5: db #61,#16,#66,#66, #18,#81,#16,#66, #18,#88,#77,#77, #18,#87,#22,#27, #18,#72,#22,#76, #17,#22,#27,#66, #77,#77,#76,#66
menicn_filesave     db 4,8,7:dw $+7,$+4,28:db 5: db #11,#11,#11,#11, #1f,#ee,#ee,#f1, #1f,#ee,#ee,#f1, #1f,#ff,#ff,#f1, #1f,#11,#c1,#f1, #1f,#11,#c1,#f1, #61,#11,#11,#11
menicn_filesaveas   db 4,8,7:dw $+7,$+4,28:db 5: db #66,#11,#11,#16, #66,#18,#88,#11, #11,#11,#11,#81, #1f,#ee,#f1,#81, #1f,#ff,#f1,#81, #1f,#11,#f1,#11, #61,#11,#11,#66
menicn_print        db 4,8,7:dw $+7,$+4,28:db 5: db #66,#61,#11,#11, #66,#18,#d8,#16, #61,#8d,#81,#66, #11,#11,#11,#16, #1a,#aa,#0a,#76, #1a,#9a,#9a,#76, #67,#77,#77,#66
menicn_quit         db 4,8,7:dw $+7,$+4,28:db 5: db #11,#16,#16,#66, #14,#46,#11,#66, #14,#11,#1e,#16, #14,#1e,#ee,#e1, #14,#11,#1e,#16, #14,#46,#11,#66, #11,#16,#16,#66

prgwinmen2tx1 db 6,128,-1:dw menicn_cut+1:          db 7:dw prgwinmen2tx1_poi:db 0
prgwinmen2tx2 db 6,128,-1:dw menicn_copy+1:         db 7:dw prgwinmen2tx2_poi:db 0
prgwinmen2tx3 db 6,128,-1:dw menicn_paste+1:        db 7:dw prgwinmen2tx3_poi:db 0
prgwinmen2tx4 db 6,128,-1:dw menicn_delete+1:       db 7:dw prgwinmen2tx4_poi:db 0
prgwinmen2tx5 db 6,128,-1:dw menicn_find+1:         db 7:dw prgwinmen2tx5_poi:db 0
prgwinmen2tx6 db 6,128,-1:dw menicn_findagain+1:    db 7:dw prgwinmen2tx6_poi:db 0
prgwinmen2tx7 db 6,128,-1:dw menicn_replace+1:      db 7:dw prgwinmen2tx7_poi:db 0
prgwinmen2tx8 db 6,128,-1:dw menicn_goto+1:         db 7:dw prgwinmen2tx8_poi:db 0
prgwinmen2tx9 db 6,128,-1:dw menicn_textall+1:      db 7:dw prgwinmen2tx9_poi:db 0
prgwinmen2txa db 6,128,-1:dw menicn_datetime+1:     db 7:dw prgwinmen2txa_poi:db 0

menicn_cut          db 4,8,7:dw $+7,$+4,28:db 5: db #61,#a6,#a1,#66, #61,#a6,#a1,#66, #66,#16,#16,#66, #66,#61,#66,#66, #66,#71,#76,#66, #67,#a7,#a7,#66, #67,#76,#77,#66
menicn_copy         db 4,8,7:dw $+7,$+4,28:db 5: db #55,#55,#56,#66, #58,#88,#56,#66, #58,#88,#57,#77, #58,#88,#50,#07, #55,#55,#50,#07, #66,#67,#00,#07, #66,#67,#77,#77
menicn_paste        db 4,8,7:dw $+7,$+4,28:db 5: db #66,#33,#36,#66, #33,#22,#23,#36, #32,#22,#22,#36, #32,#55,#55,#55, #33,#58,#88,#85, #66,#58,#88,#85, #66,#55,#55,#55
menicn_delete       db 4,8,7:dw $+7,$+4,28:db 5: db #ff,#66,#66,#ff, #6f,#f6,#6f,#f6, #66,#ff,#ff,#66, #66,#6f,#f6,#66, #66,#ff,#ff,#66, #6f,#f6,#6f,#f6, #ff,#66,#66,#ff
menicn_find         db 4,8,7:dw $+7,$+4,28:db 5: db #66,#16,#61,#66, #61,#71,#17,#16, #61,#71,#17,#16, #17,#71,#17,#71, #18,#16,#61,#81, #17,#16,#61,#71, #11,#16,#61,#11
menicn_findagain    db 4,8,7:dw $+7,$+4,28:db 5: db #61,#66,#16,#66, #67,#11,#76,#f6, #17,#11,#71,#f6, #18,#11,#81,#f6, #17,#66,#71,#f6, #11,#66,#1f,#ff, #66,#66,#66,#f6
menicn_replace      db 4,8,7:dw $+7,$+4,28:db 5: db #66,#61,#11,#16, #66,#61,#88,#11, #33,#33,#88,#81, #33,#63,#38,#81, #33,#33,#88,#81, #33,#63,#31,#11, #33,#63,#36,#66
menicn_goto         db 4,8,7:dw $+7,$+4,28:db 5: db #66,#66,#66,#f6, #ff,#ff,#ff,#ff, #66,#66,#66,#f6, #61,#16,#61,#66, #16,#66,#16,#16, #16,#16,#16,#16, #61,#16,#61,#66
menicn_textall      db 4,8,7:dw $+7,$+4,28:db 5: db #ff,#ff,#ff,#ff, #88,#88,#88,#86, #ff,#ff,#ff,#f6, #88,#88,#86,#66, #ff,#ff,#f6,#66, #88,#88,#88,#66, #ff,#ff,#ff,#66
menicn_datetime     db 4,8,7:dw $+7,$+4,28:db 5: db #66,#77,#77,#66, #67,#8a,#18,#76, #78,#88,#18,#87, #7a,#81,#88,#a7, #78,#18,#88,#87, #67,#88,#a8,#76, #66,#77,#77,#66

prgwinmen3tx1 db 6,128,-1:dw menicn_null+1:         db 7:dw prgwinmen3tx1_poi:db 0
prgwinmen3tx2 db 6,128,-1:dw menicn_settings+1:     db 7:dw prgwinmen3tx2_poi:db 0

;     _wordwrap
menicn_settings     db 4,8,7:dw $+7,$+4,28:db 5: db #66,#6c,#66,#66, #6c,#6c,#6c,#66, #6f,#cd,#cf,#66, #cc,#c1,#cc,#c6, #ff,#cc,#cf,#f6, #6c,#fc,#fc,#66, #6f,#6c,#6f,#66

prgwinmen4tx1 db 6,128,-1:dw menicn_null+1:         db 7:dw prgwinmen4tx1_poi:db 0

;     _viewstatus
prgwinmen5tx1 db 6,128,-1:dw menicn_help+1:         db 7:dw prgwinmen5tx1_poi:db 0
prgwinmen5tx2 db 6,128,-1:dw menicn_about+1:        db 7:dw prgwinmen5tx2_poi:db 0

menicn_help         db 4,8,7:dw $+7,$+4,28:db 5: db #66,#1f,#f1,#66, #61,#fc,#cf,#16, #1f,#ff,#fc,#f1, #ff,#fc,#cc,#f1, #ff,#ff,#ff,#18, #1f,#cf,#f1,#81, #61,#ff,#18,#16
menicn_about        db 4,8,7:dw $+7,$+4,28:db 5: db #66,#10,#07,#66, #66,#10,#07,#66, #66,#66,#66,#66, #61,#00,#07,#66, #66,#10,#07,#66, #66,#10,#07,#66, #61,#00,#00,#76

;### ALERT BOXES ##############################################################

prgtxtinf  dw prgtxtinf1,4*1+2,prgtxtinf2,4*1+2,prgtxtinf3,4*1+2,0,prgicnbig,prgicn16c

prgtxterr1  dw prgtxterra,4*1+2,prgtxterrb,4*1+2,prgtxtinf0,4*1+2
prgtxterr2  dw prgtxterrc,4*1+2,prgtxtinf0,4*1+2,prgtxtinf0,4*1+2
prgtxterr3  dw prgtxterrd,4*1+2,prgtxtinf0,4*1+2,prgtxtinf0,4*1+2
prgtxterr4  dw prgtxterre,4*1+2,prgtxterrf,4*1+2,prgtxtinf0,4*1+2
prgtxterr5  dw prgtxterrg,4*1+2,prgtxtinf0,4*1+2,prgtxtinf0,4*1+2   ;no printer daemon

prgtxtsav   dw prgtxtsav1,4*1+2,prgtxtinf0,4*1+2,prgtxtinf0,4*1+2

prgtxtfnd   dw fndmsgtxt1,4*1+2,prgtxtinf0,4*1+2,prgtxtinf0,4*1+2
prgtxtrep   dw fndmsgtxt2a,4*1+2,prgtxtinf0,4*1+2,prgtxtinf0,4*1+2,prgicnbig
prgtxtmem   dw fndmsgtxt3a,4*1+2,fndmsgtxt3b,4*1+2,prgtxtinf0,4*1+2
prgtxtnum   dw fndmsgtxt4,4*1+2,prgtxtinf0,4*1+2,prgtxtinf0,4*1+2

;### PRINTING WINDOW ##########################################################

winprtdat   dw #0081,4+8+16, 0,0, 90, 20,0,0, 90, 20, 90, 20, 90, 20,0,0,0,0,winprtgrp,0,0:ds 136+14
winprtgrp   db 2,0: dw winprtrec,0,0:db 0,0:dw 0,0,0
winprtrec   dw 0,255*256+ 0,2,        0,0,1000,1000,0
            dw 0,255*256+ 1,ctrprt1,0, 8, 90,   8,0

ctrprt1     dw txtprt1:dw 256*2+4*1+2
txtprt1     db "Printing...",0

;### CONFIG WINDOW ############################################################

cfgwindat   dw #1401,4+16,079,024,160,138,0,0,160,138,160,138,160,138,0,cfgwintit,0,0,cfgwingrp,0,0:ds 136+14
cfgwingrp   db 20,0:dw cfgwinobj,0,0,256*20+19,0,0,0
cfgwinobj
dw     00,         0,2,          0,0,1000,1000,0        ;00=Hintergrund
dw     00,255*256+ 3,cfgwindsc0, 00, 01, 80,59,0        ;01=Frame       "Font type"
dw     00,255*256+41,fntselobj,  08, 10, 64,42,0        ;02=Font-List
dw     00,255*256+ 3,cfgwindsc1, 80, 01, 80,59,0        ;03=Frame       "Font colour"
dw     00,255*256+ 1,cfgwindsc6, 88, 12, 32, 8,0        ;04=Description "Pen"
dw cfgcol,255*256+42,penselobj, 120, 11, 32,10,0        ;05=Pen-List
dw     00,255*256+ 1,cfgwindsc7, 88, 24, 32, 8,0        ;06=Description "Paper"
dw cfgcol,255*256+42,papselobj, 120, 23, 32,10,0        ;07=Paper-List
dw     00,255*256+ 1,cfgwindsc8, 92, 40, 56, 8,0        ;08=Description "Preview"
dw     00,255*256+ 3,cfgwindsc2, 00, 60,160,63,0        ;09=Frame       "Options"
dw     00,255*256+18,cfgwinrad0, 08, 70,120, 8,0        ;10=Radiobox    "Word wrap at window border"
dw     00,255*256+18,cfgwinrad1, 08, 81, 64, 8,0        ;11=Radiobox    "Word wrap at"
dw     00,255*256+32,cfgwininp1, 73, 79, 26,12,0        ;12=Input       "Word wrap at"
dw     00,255*256+ 1,cfgwindsc4,101, 81, 32, 8,0        ;13=Description "px"
dw     00,255*256+18,cfgwinrad2, 08, 92, 64, 8,0        ;14=Radiobox    "No word wrap"
dw     00,255*256+ 1,cfgwindsc3, 08,106, 32, 8,0        ;15=Description "Tab stop width"
dw     00,255*256+32,cfgwininp2, 73,104, 16,12,0        ;16=Input       "Tab stop width"
dw     00,255*256+ 1,cfgwindsc5, 91,106, 32, 8,0        ;17=Description "chars"
dw cfgoky,255*256+16,prgtxtoky,  59,123, 48,12,0        ;18="Ok"    -Button
dw diacnc,255*256+16,prgtxtcnc, 109,123, 48,12,0        ;19="Cancel"-Button


fntselobj   dw 8,0,fntsellst,0,1,fntselrow,0,1
fntselrow   dw 0,56,0,0
fntsellst   dw 00,fnttxtdef
            dw 01,fnttxtdef, 02,fnttxtdef, 03,fnttxtdef, 04,fnttxtdef, 05,fnttxtdef, 06,fnttxtdef, 07,fnttxtdef, 08,fnttxtdef
            dw 09,fnttxtdef, 10,fnttxtdef, 11,fnttxtdef, 12,fnttxtdef, 13,fnttxtdef, 14,fnttxtdef, 15,fnttxtdef, 16,fnttxtdef

penselobj   dw 16,0,pensellst,0,1,penselrow,0,1
penselrow   dw 0,56,0,0
pensellst   dw 00,coltxt00, 01,coltxt01, 02,coltxt02, 03,coltxt03, 04,coltxt04, 05,coltxt05, 06,coltxt06, 07,coltxt07
            dw 08,coltxt08, 09,coltxt09, 10,coltxt10, 11,coltxt11, 12,coltxt12, 13,coltxt13, 14,coltxt14, 15,coltxt15

papselobj   dw 16,0,papsellst,0,1,papselrow,0,1
papselrow   dw 0,56,0,0
papsellst   dw 00,coltxt00, 01,coltxt01, 02,coltxt02, 03,coltxt03, 04,coltxt04, 05,coltxt05, 06,coltxt06, 07,coltxt07
            dw 08,coltxt08, 09,coltxt09, 10,coltxt10, 11,coltxt11, 12,coltxt12, 13,coltxt13, 14,coltxt14, 15,coltxt15

cfgwindsc0  dw cfgwintxt0,2+4
cfgwindsc1  dw cfgwintxt1,2+4
cfgwindsc2  dw cfgwintxt2,2+4
cfgwindsc3  dw cfgwintxt7,2+4
cfgwindsc4  dw cfgwintxt5,2+4
cfgwindsc5  dw cfgwintxt8,2+4
cfgwindsc6  dw cfgwintxt9,2+4
cfgwindsc7  dw cfgwintxta,2+4
cfgwindsc8  dw cfgwintxtb,256*194+16

cfgwininp1  dw cfgwinbuf1,0,0,0,0,4,0
cfgwinbuf1  ds 5
cfgwininp2  dw cfgwinbuf2,0,0,0,0,2,0
cfgwinbuf2  ds 3

cfgwinwrp   db 0
cfgwinradb  dw -1,-1
cfgwinrad0  dw cfgwinwrp,cfgwintxt3,256*0+2+4,cfgwinradb
cfgwinrad1  dw cfgwinwrp,cfgwintxt4,256*1+2+4,cfgwinradb
cfgwinrad2  dw cfgwinwrp,cfgwintxt6,256*2+2+4,cfgwinradb

cfgdat
cfgdatpap   db 0    ;paper
cfgdatpen   db 1    ;pen
cfgdatfnt   db 0    ;font 
cfgdatwrp   db 0    ;0=autowordwrap, 1=wordwrap at position x, 2=no wordwrap
cfgdatwps   dw 200  ;wordwrap-position (pixels)
cfgdattab   db 8    ;tabstop-position (chars)
cfgdatsta   db 1    ;flag, if statusbar
            ds 16-8

cfgfntnum   db 0        ;number of fonts
cfgfntdat   ds 254-16   ;font information (number/offset table, names)
cfgfntcpr   db 0        ;flag, if fonts compressed

;### GOTO #####################################################################

gotwindat   dw #1401,4+16,090,060,120,34,0,0,120,34,120,34,120,34,0,gotwintit,0,0,gotwingrp,0,0:ds 136+14
gotwingrp   db 07,0:dw gotwinobj,0,0,256*07+06,0,0,3
gotwinobj
dw     00,         0,2,          0,0,1000,1000,0        ;00=Hintergrund
dw     00,255*256+ 1,gotwindsc1, 04, 06, 34, 8,0        ;01=Description "Line"
dw     00,255*256+32,gotdatoln,  38, 04, 32,12,0        ;02=Input       "Line"
dw     00,255*256+ 1,gotwindsc2, 04, 20, 34, 8,0        ;03=Description "Column"
dw     00,255*256+32,gotdatocl,  38, 18, 32,12,0        ;04=Input       "Column"
dw fndgot,255*256+16,prgtxtoky,  76, 04, 40,12,0        ;05="Ok"        -Button
dw diacnc,255*256+16,prgtxtcnc,  76, 18, 40,12,0        ;06="Cancel"    -Button

gotwindsc1  dw fndwintxt6,2+4
gotwindsc2  dw fndwintxt7,2+4
gotdatoln   dw gotdattln,0,1,0,1,4,0
gotdatocl   dw gotdattcl,0,1,0,1,5,0

;### FIND AND REPLACE #########################################################

fndwindat   dw #1401,4+16,060,060,240,46,0,0,240,46,240,46,240,46,0,fndwintit,0,0,fndwingrp,0,0:ds 136+14
fndwingrp   db 07,0:dw fndwinobj,0,0,256*07+06,0,0,3
fndwinobj
dw     00,         0,2,          0,0,1000,1000,0        ;00=Hintergrund
dw     00,255*256+ 1,fndwindsc1, 04, 06, 40, 8,0        ;01=Description "Find what"
dw     00,255*256+32,fnddatofn,  60, 04,114,12,0        ;02=Input       "Find what"
dw     00,255*256+17,fndwinchk1, 04, 24, 80, 8,0        ;03=Checkbox    "Match case"
dw     00,255*256+17,fndwinchk2, 04, 34, 80, 8,0        ;04=Checkbox    "Whole word only"
dw fndfok,255*256+16,prgtxtfnx, 182, 04, 54,12,0        ;05="Find next" -Button
dw diacnc,255*256+16,prgtxtcnc, 182, 20, 54,12,0        ;06="Cancel"    -Button

repwindat   dw #1401,4+16,060,060,240,70,0,0,240,70,240,70,240,70,0,repwintit,0,0,repwingrp,0,0:ds 136+14
repwingrp   db 11,0:dw repwinobj,0,0,256*11+09,0,0,3
repwinobj
dw     00,         0,2,          0,0,1000,1000,0        ;00=Hintergrund
dw     00,255*256+ 1,fndwindsc1, 04, 06, 40, 8,0        ;01=Description  "Find what"
dw     00,255*256+32,fnddatofn,  60, 04,114,12,0        ;02=Input        "Find what"
dw     00,255*256+ 1,fndwindsc2, 04, 20, 40, 8,0        ;03=Description  "Replace with"
dw     00,255*256+32,fnddatorp,  60, 18,114,12,0        ;04=Input        "Replace with"
dw     00,255*256+17,fndwinchk1, 04, 38, 80, 8,0        ;05=Checkbox     "Match case"
dw     00,255*256+17,fndwinchk2, 04, 48, 80, 8,0        ;06=Checkbox     "Whole word only"
dw     00,255*256+17,fndwinchk3, 04, 58, 80, 8,0        ;07=Checkbox     "Entire document"
dw fndrok,255*256+16,prgtxtfnx, 182, 04, 54,12,0        ;08="Find next"  -Button
dw fndral,255*256+16,prgtxtfra, 182, 20, 54,12,0        ;09="Replace all"-Button
dw diacnc,255*256+16,prgtxtcnc, 182, 36, 54,12,0        ;10="Cancel"     -Button

rplwindat   dw #1401,4+16,060,060,226,24,0,0,226,24,226,24,226,24,0,repwintit,0,0,rplwingrp,0,0:ds 136+14
rplwingrp   db 5,0:dw rplwinobj,0,0,256*5+3,0,0,2
rplwinobj
dw     00,         0,2,          0,0,1000,1000,0        ;00=Hintergrund
dw fndrok,255*256+16,prgtxtfnx,   2, 6, 54,12,0         ;01="Find next"  -Button
dw fndrdr,255*256+16,prgtxtfrp,  58, 6, 54,12,0         ;02="Replace"    -Button
dw fndrda,255*256+16,prgtxtfra, 114, 6, 54,12,0         ;03="Replace all"-Button
dw diacnc,255*256+16,prgtxtcnc, 170, 6, 54,12,0         ;04="Cancel"     -Button

fndwindsc1  dw fndwintxt1,2+4
fndwindsc2  dw fndwintxt2,2+4

fndwinchk1  dw fnddatcas,fndwintxt3,2+4
fndwinchk2  dw fnddatwrd,fndwintxt4,2+4
fndwinchk3  dw fnddatall,fndwintxt5,2+4

fnddatofn   dw fnddattfn,0,0,0,0,32,0
fnddatorp   dw fnddattrp,0,0,0,0,32,0
fnddatcas   db 0    ;flag, if case-sensitive
fnddatwrd   db 0    ;flag, if whole word only
fnddatall   db 0    ;flag, if entire document

;### FONT DROPDOWN ############################################################

fntwindat dw #0001,4+8+16, 33, 20,58,90,0,0,1000,1000,1,1,1000,1000,0,0,0,0,fntwingrp,0,0:ds 136+14

fntwingrp   db 1,0:dw fntwinrec,0,0,00*256+00,0,0,00
fntwinrec
dw     00,255*256+25,fntcolctr,00,00,58,90,0           ;00=control collection

fntcolctr   dw fntcolgrp,58,110,0,0,2

fntcolgrp   db fntcfgnum+2,0:dw fntcolrec,0,0,00*256+00,0,0,00
fntcolrec
dw     00,255*256+00,128+8     ,0,0,10000,10000,0       ;00=Background
dw     01,255*256+10,0         ,001, 0,16,14,0          ;01=font 00
dw     02,255*256+10,0         ,001, 0,16,14,0          ;02=font 01
dw     03,255*256+10,0         ,001, 0,16,14,0          ;03=font 02
dw     04,255*256+10,0         ,001, 0,16,14,0          ;04=font 03
dw     05,255*256+10,0         ,001, 0,16,14,0          ;05=font 04
dw     06,255*256+10,0         ,001, 0,16,14,0          ;06=font 05
dw     07,255*256+10,0         ,001, 0,16,14,0          ;07=font 06
dw     08,255*256+10,0         ,001, 0,16,14,0          ;08=font 07
dw     09,255*256+10,0         ,001, 0,16,14,0          ;09=font 08
dw     10,255*256+10,0         ,001, 0,16,14,0          ;10=font 09
dw     11,255*256+10,0         ,001, 0,16,14,0          ;11=font 10
dw    255,255*256+00,192+9     ,001, 0,48,10,0          ;12=marker


;### MAIN WINDOW ##############################################################

prgwindat dw #7f01,3,50,20,200,106,0,0,200,106,100,50,10000,10000,prgicnsml,prgwintit
prgwindat0 dw prgwinsta,prgwinmen,prgwingrp,prgtolgrp,17:ds 136+14

prgwinmen  dw  5, 1+4,prgwinmentx1,prgwinmen1,0, 1+4,prgwinmentx2,prgwinmen2,0, 1+4,prgwinmentx3,prgwinmen3,0, 1+4,prgwinmentx4,prgwinmen4,0, 1+4,prgwinmentx5,prgwinmen5,0
prgwinmen1 dw  8, 33,prgwinmen1tx1,filnew,0, 33,prgwinmen1tx2,filopn,0, 33,prgwinmen1tx3,filsav,0, 33,prgwinmen1tx4,filsas,0, 1+8,0,0,0, 33,prgwinmen1tx5,filprt,0, 1+8,0,0,0, 33,prgwinmen1tx6,prgend0,0
prgwinmen2 dw 12, 33,prgwinmen2tx1,edtcut,0, 33,prgwinmen2tx2,edtcop,0, 33,prgwinmen2tx3,edtpas,0, 33,prgwinmen2tx4,edtdel,0, 1+8,0,0,0, 33,prgwinmen2tx5,fndfnd,0
           dw     33,prgwinmen2tx6,fndfnx,0, 33,prgwinmen2tx7,fndrep,0, 33,prgwinmen2tx8,edtgot,0, 1+8,0,0,0, 33,prgwinmen2tx9,edtsal,0, 33,prgwinmen2txa,edttim,0
prgwinmen3 dw  2, 33,prgwinmen3tx1,cfgwrp,0, 33,prgwinmen3tx2,cfgopn,0
prgwinmen4 dw  1, 33,prgwinmen4tx1,cfgbar,0
prgwinmen5 dw  3, 33,prgwinmen5tx1,prghlp,0, 1+8,0,0,0, 33,prgwinmen5tx2,prginf,0

prgtolgrp db 13,0:dw prgtolrec,0,0,256*0+0,0,0,2
prgtolrec
dw     00,255*256+0, 128+06,  0,0,10000,10000,0       ;00=Background1
dw filnew,255*256+10,gfxtola,    1,  1, 16,14,0       ;01=Button "New"
dw filopn,255*256+10,gfxtolb,   17,  1, 16,14,0       ;02=Button "Open"
dw filsav,255*256+10,gfxtolc,   33,  1, 16,14,0       ;03=Button "Save"
dw filprt,255*256+10,gfxtold,   49,  1, 16,14,0       ;04=Button "Print"
dw      0,255*256+0, 1,         67,  0,  1,16,0       ;05=seperator
prgtolrec_fntdrp equ 5
prgtolrec_fntdrp_adr
dw drpfnt,255*256+0, 128+8,     70,  2, 50,12,0       ;06=font dropdown frame
dw drpfnt,255*256+10,bmpfntdef, 71,  5, 26, 6,0       ;07=font dropdown text
dw drpfnt,255*256+10,arrdwngfx,120,  4,  8, 8,0       ;08=font dropdown arrow

dw stybld,255*256+10,gfxtole,  130,  1, 16,14,0       ;09=Button "Bold"
dw styita,255*256+10,gfxtolf,  146,  1, 16,14,0       ;10=Button "Italics"
dw styuln,255*256+10,gfxtolg,  162,  1, 16,14,0       ;11=Button "Underlined"
prgtolrec0
dw stymrk,255*256+ 0,1+128+64, -16,  2, 13,12,0       ;12=marked formatting

prgtolreci  equ 9   ;id  of first formatting button
prgtolrecn  equ 3   ;num of formatting buttons
prgtolrecp  equ 130 ;pos of first formatting button


prgwingrp db 2,0:dw prgwinobj,prgwinclc,0,256*0+0,0,0,2
prgwinobj
dw     00,255*256+00,128+8     ,0,0,0,0,0   ;00=Background
dw edtchg,255*256+33,txtmulobj ,0,0,0,0,0   ;01=Editor

prgwinclc
dw   0,      0,  0,  0,10000,      0,10000,    0    ;Background
dw   1,      0,  1,  0,  -2,256*1+1, -2,256*1+1     ;Editor

fntdrpobj   dw 8,0,fntsellst,0,1,fntselrow
fntdrpobj0  dw 0,1  ;selected font

txtmulobj   dw txtbufmem    ;texdatadr       equ 0           ;Zeiger auf Text
            dw 0            ;texdatbeg       equ 2           ;erstes angezeigtes Zeichen (nur singleline)
            dw 0            ;texdatpos       equ 4           ;Cursorposition im Gesamttext
            dw 0            ;texdatmrk       equ 6           ;0/Anzahl markierter Zeichen [neg->Cursor=Ende Markierung]
            dw 0            ;texdatlen       equ 8           ;Textlänge
            dw txtbufmax    ;texdatmax       equ 10          ;maximal zulässige Textlänge (1-16383; exklusive 0-Terminator)
            db 4            ;texdatflg       equ 12          ;Flags (Bit0=Paßwort [nur singleline], Bit1=ReadOnly, Bit2=AltColor, Bit3=AltFont [nur multiline], Bit4=keymapping, Bit7=Text has been modified)
                            ;;** extended 16c/altfont
            db 0+16         ;texdatcol       equ 13          ;4bit txtpap, 4bit txtpen
            db 0            ;texdatrhm       equ 14          ;4bit rahmen1, 4bit rahmen2 (nur singleline)
            dw 0            ;texdatfnt       equ 15          ;Adresse des alternativen Fonts
            ds 1            ;texdatrs1       equ 17          ;*reserved 2byte*
                            ;;** ab hier nur Multiline
            dw 0            ;texdatlnt       equ 18          ;aktuelle Anzahl Zeilen
            dw -1           ;texdatxmx       equ 20          ;maximale Zeilenbreite in Pixeln bei Wordwrap-Pos-Vorgabe (-1=unbegrenzt)
            dw txtlinmax    ;texdatymx       equ 22          ;maximale Anzahl Zeilen (*2 bytes ab texdatlln!)
            dw -8           ;texdatxwn       equ 24          ;win y len ohne slider für bisherige formatierung (winx<>aktx -> Neuformatierung notwendig, durch -8 erzwingen)
            dw 0            ;texdatywn       equ 26          ;win y len ohne slider
                            ;
            dw txtmulobj    ;texdatzgr       equ 28          ;pointer auf diesen datensatz
            dw 120          ;texdatxfl       equ 30          ;full x len (=Länge der längsten Textzeile in Pixel)
            dw 80           ;texdatyfl       equ 32          ;full y len (=Anzahl aller Textzeilen * 8)
            dw 0            ;texdatxof       equ 34          ;offset x
            dw 0            ;texdatyof       equ 36          ;offset y
            db 1+2          ;texdatfg2       equ 38          ;Flags (Bit0=kein Auto-WordWrap [dann Xslider], Bit1=1)
            db 0            ;texdattab       equ 39          ;Tabstop Größe (1-255; 0=kein Tabstop)
                            ;
            ds 4            ;texdatmsg       equ 40          ;Message-Buffer (in POS, MRK, out CXP, CYP)
            ds 2            ;texdatrs2       equ 44          ;*reserved 4byte*
            dw 0            ;texdatkmp       equ 46          ;keymap
            db 0            ;texdatlln       equ 48          ;Zeilen-Längentabelle (bit15=cr+lf am ende vorhanden, wird mitgezählt)
;!!!last line in transfer-area!!!
