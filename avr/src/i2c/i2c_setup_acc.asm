.equ acc_reg_ctrl = 0x20

.equ a_xen = 0 ;(x enable) 0: X axis disabled; 1: X axis enabled
.equ a_yen = 1 ;(y enable) 0: Y axis disabled; 1: Y axis enabled
.equ a_zen = 2 ;(z enable) 0: Z axis disabled; 1: Z axis enabled
.equ a_fs = 5 ;(full scale) 0: +-2.3g 18mg/digit, 1: +-9.2g, 72mg/digit
.equ a_pd = 6 ;(Power Down Ctrl) 0: power down mode, 1: active mode
.equ a_dr = 7 ;(Data Rate Selection) 0: 100 Hz output, 1: 400 Hz output

.equ acc_ctrl_val = (1<<a_xen)|(1<<a_yen)|(1<<a_zen)|(1<<a_fs)|(1<<a_pd)|(1<<a_dr)

I2C_ID_WRITE [acc_addr_w, acc_reg_ctrl, acc_ctrl_val]
