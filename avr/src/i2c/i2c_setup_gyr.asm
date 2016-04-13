.equ gyr_reg_ctrl1 = 0x20
.equ g_xen = 0 ;(x enable) 0: X axis disabled; 1: X axis enabled
.equ g_yen = 1 ;(y enable) 0: Y axis disabled; 1: Y axis enabled
.equ g_zen = 2 ;(z enable) 0: Z axis disabled; 1: Z axis enabled
.equ g_pd = 3 ;(Power Down Ctrl) 0: power down mode, 1: active mode
.equ g_bw0 = 4 ;(Bandwith Selection) Se side 29-30 i databladet
.equ g_bw1 = 5 ;
.equ g_dr0 = 6 ;(Data Rate Selection) Se side 29-30 i databladet
.equ g_dr1 = 7 ; dr1:dr0 = 0b10 -> 400 Hz
.equ gyr_ctrl1_axes = (1<<g_zen)|(1<<g_yen)|(1<<g_xen)
.equ gyr_ctrl1_bw = (1<<g_bw1)|(0<<g_bw0)
.equ gyr_ctrl1_dr = (1<<g_dr1)|(0<<g_dr0)
.equ gyr_ctrl1_val = (1<<g_pd)|gyr_ctrl1_dr|gyr_ctrl1_bw|gyr_ctrl1_axes
I2C_ID_WRITE [gyr_addr_w, gyr_reg_ctrl1, gyr_ctrl1_val]

.equ gyr_reg_ctrl4 = 0x23
.equ g_fs0 = 4 ;(Full Scale Selection)
.equ g_fs1 = 5 ;Se datablad s. 32
.equ gyr_ctrl4_val = (0<<g_fs1)|(1<<g_fs0) ; sensitivity / range
I2C_ID_WRITE [gyr_addr_w, gyr_reg_ctrl4, gyr_ctrl4_val]

.equ gyr_reg_ctrl5 = 0x24
.equ g_out_sel0 = 0
.equ g_out_sel1 = 1
.equ gyr_ctrl5_val = (0<<g_out_sel1) ; low pass filter
I2C_ID_WRITE [gyr_addr_w, gyr_reg_ctrl5, gyr_ctrl5_val]
