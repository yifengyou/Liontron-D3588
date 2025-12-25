# D3588 (Rockchip RK3588) 玩耍记录


```
Something I hope you know before go into the coding~
First, please watch or star this repo, I'll be more happy if you follow me.
Bug report, questions and discussion are welcome, you can post an issue or pull a request.
```

## 相关站点

* 亮钻官网: <http://www.liontron.cn/showinfo-136-230-0.html>


## 开发板信息

```
Machine model: Rockchip RK3588 DXB LP4 V10 Board
```

![](./images/3297246892200.jpg)


![](./images/264857059457700.png)

![](./images/264879429216000.png)

![](./images/265672876138200.png)

![](./images/265700618727999.png)

## 高透亚克力外壳



![](./images/7076967996200.jpg)

![](./images/7077000278800.jpg)

![](./images/7077017714700.jpg)

![](./images/7077035046700.jpg)

![](./images/7077047251600.jpg)

![](./images/7077064809000.jpg)

![](./images/7077082941500.jpg)

![](./images/7077100498900.jpg)

![](./images/7077116965900.jpg)

![](./images/7156696863900.jpeg)

* 外壳购买方式: 扫描上图二维码，跳转闲鱼购买
  - 高透亚克力材质
  - 支持2.5寸硬盘，预留孔位
  - 支持4cm/6cm散热风扇，预留孔位
  - 长165mm 宽110mm 高61.6mm 厚度5mm
  - 带m3铜柱，结实稳固
  - 预留ttl串口调试线孔位


  

---



## 固件/镜像操作指引


### boot.img


#### boot.img类别一 非标准Android bootimg

file目标文件类型显示为Android bootimg

```text
# file zboot.img
zboot.img: Android bootimg, kernel (0x10008000), second stage (0x10f00000), page size: 2048
# binwalk zboot.img 

DECIMAL       HEXADECIMAL     DESCRIPTION
--------------------------------------------------------------------------------
0             0x0             Android bootimg, kernel size: 15232835 bytes, kernel addr: 0x10008000, ramdisk size: 0 bytes, ramdisk addr: 0x0, product name: ""
2048          0x800           LZ4 compressed data
98991         0x182AF         SHA256 hash constants, little endian
1710679       0x1A1A57        bix header, header size: 64 bytes, header CRC: 0x940035FF, created: 2105-07-29 04:52:16, image size: 837030656 bytes, Data Address: 0xB89E1E80, Entry Point: 0x80000D80, data CRC: 0x5F12A9, image name: ""
6779907       0x677403        bix header, header size: 64 bytes, header CRC: 0x50D52103, created: 2076-10-14 00:41:04, image size: 1388466361 bytes, Data Address: 0x2160027C, Entry Point: 0x3863, data CRC: 0x5B2300C0, compression type: none, image name: ""
9035084       0x89DD4C        LZ4 compressed data
10323048      0x9D8468        SHA256 hash constants, little endian
10642729      0xA26529        lzop compressed data, - version 0.03b,
10761734      0xA43606        AES Inverse S-Box
10958430      0xA7365E        Certificate in DER format (x509 v3), header length: 4, sequence length: 676
12078269      0xB84CBD        xz compressed data
12208373      0xBA48F5        Cisco IOS microcode, for "8_MAXj"
14650713      0xDF8D59        MPEG transport stream data
14906633      0xE37509        AES S-Box
14906889      0xE37609        AES Inverse S-Box
15237120      0xE88000        Flattened device tree, size: 158675 bytes, version: 17
15395840      0xEAEC00        PC bitmap, Windows 3.x format,, 654 x 270 x 8
15409152      0xEB2000        PC bitmap, Windows 3.x format,, 654 x 270 x 8
```

制作zboot.img镜像

```shell

+ ./scripts/bmpconvert ./logo.bmp
+ ./scripts/bmpconvert ./logo_kernel.bmp

+ scripts/resource_tool ./arch/arm64/boot/dts/rockchip/rk3588-evb7-lp4-v10-linux.dtb logo.bmp logo_kernel.bmp
+ echo '  Image:  resource.img (with rk3588-evb7-lp4-v10-linux.dtb logo.bmp logo_kernel.bmp) is ready'

+ make_boot_img
+ RAMDISK_IMG_PATH=./ramdisk.img

+ ./scripts/mkbootimg --kernel ./arch/arm64/boot/Image --second resource.img -o boot.img
  Image:  boot.img (with Image  resource.img) is ready

+ ./scripts/mkbootimg --kernel ./arch/arm64/boot/Image.lz4 --second resource.img -o zboot.img
```

* boot.img    Image（原始内核）	未压缩	标准启动镜像（调试/开发用）
* zboot.img   Image.lz4（压缩内核）	LZ4压缩	节省存储空间（量产/发布用）


拆解zboot.img

```shell
mkdir -p yyf
# ./scripts/unpack_bootimg --boot_img zboot.img --out yyf/
boot_magic: ANDROID!
kernel_size: 15232835
kernel load address: 0x10008000
ramdisk size: 0
ramdisk load address: 0x0
second bootloader size: 196608
second bootloader load address: 0x10f00000
kernel tags load address: 0x10000100
page size: 2048
os version: 0.0.0
os patch level: 2000-00
boot image header version: 0
product name: 
command line args: 
additional command line args: 

# ll yyf
total 15M
drwxr-xr-x  2 root   root   4.0K Jun 24 22:11 .
drwxrwx--- 31 debian debian 4.0K Jun 24 21:31 ..
-rw-r--r--  1 root   root    15M Jun 24 22:10 kernel
-rw-r--r--  1 root   root      0 Jun 24 22:10 ramdisk
-rw-r--r--  1 root   root   192K Jun 24 22:10 second

# ../scripts/resource_tool --unpack --image=second 
Dump header:
partition version:0.0
header size:1
index tbl:
	offset:1	entry size:1	entry num:3
Dump Index table:
entry(0):
	path:rk-kernel.dtb
	offset:4	size:158675
entry(1):
	path:logo.bmp
	offset:314	size:12936
entry(2):
	path:logo_kernel.bmp
	offset:340	size:22364
Unack second to out successed!

# ls -alh out
total 204K
drwxr-xr-x 2 root root 4.0K Jun 24 22:11 .
drwxr-xr-x 3 root root 4.0K Jun 24 22:11 ..
-rw-r--r-- 1 root root  13K Jun 24 22:11 logo.bmp
-rw-r--r-- 1 root root  22K Jun 24 22:11 logo_kernel.bmp
-rw-r--r-- 1 root root 155K Jun 24 22:11 rk-kernel.dtb



```


### boot.img类别二

file目标boot.img显示为Device Tree Blob

```shell
# file boot.img
boot.img: Device Tree Blob version 17, size=1536, boot CPU=0, string block size=190, DT structure block size=1004
[root@7945HX /rockchip/d3588/official-firmware/rk3588dt-l14-oem-debian11-250214/rockdev/image]# binwalk boot.img

DECIMAL       HEXADECIMAL     DESCRIPTION
--------------------------------------------------------------------------------
0             0x0             Flattened device tree, size: 1536 bytes, version: 17
2048          0x800           Flattened device tree, size: 183425 bytes, version: 17
185856        0x2D600         Linux kernel ARM64 image, load offset: 0x0, image size: 33947648 bytes, little endian, 4k page size,
480256        0x75400         SHA256 hash constants, little endian
18572800      0x11B6600       ELF, 64-bit LSB shared object, version 1 (SYSV)
18578480      0x11B7C30       SHA256 hash constants, little endian
18594608      0x11BBB30       gzip compressed data, maximum compression, from Unix, last modified: 1970-01-01 00:00:00 (null date)
19122272      0x123C860       DES SP2, little endian
19122784      0x123CA60       DES SP1, little endian
19146240      0x1242600       CRC32 polynomial table, little endian
19172136      0x1248B28       LZO compressed data
19457530      0x128E5FA       LZMA compressed data, properties: 0x6D, dictionary size: 0 bytes, uncompressed size: 256 bytes
19781787      0x12DD89B       LZMA compressed data, properties: 0x65, dictionary size: 0 bytes, uncompressed size: 2048 bytes
20190294      0x1341456       Intel x86 or x64 microcode, sig 0x00000008, pf_mask 0x2000000, 2000-08-08, size 256
20190322      0x1341472       Intel x86 or x64 microcode, pf_mask 0x2000000, 2000-10-08, rev 0x0100, size 256
20204854      0x1344D36       Intel x86 or x64 microcode, sig 0x00000008, pf_mask 0x2000000, 2000-08-08, size 256
20204882      0x1344D52       Intel x86 or x64 microcode, pf_mask 0x2000000, 2000-10-08, rev 0x0100, size 256
20205350      0x1344F26       Intel x86 or x64 microcode, sig 0x00000008, pf_mask 0x2000000, 2000-08-08, size 256
20205378      0x1344F42       Intel x86 or x64 microcode, pf_mask 0x2000000, 2000-10-08, rev 0x0100, size 256
20207070      0x13455DE       Intel x86 or x64 microcode, pf_mask 0x2000000, 2000-10-08, rev 0x0100, size 256
20505715      0x138E473       Neighborly text, "neighbor get requestrequest"
20505765      0x138E4A5       Neighborly text, "neighbor get request get request"
20505820      0x138E4DC       Neighborly text, "neighbor get request"
20506121      0x138E609       Neighborly text, "neighbor get requestrequest"
20506171      0x138E63B       Neighborly text, "neighbor get requestest"
20506217      0x138E669       Neighborly text, "neighbor get request"
20506259      0x138E693       Neighborly text, "neighbor dump requestbor dump request"
20506317      0x138E6CD       Neighborly text, "neighbor dump request dump request"
20506372      0x138E704       Neighborly text, "neighbor dump request attribute in neighbor dump request"
20506449      0x138E751       Neighborly text, "neighbor dump request"
20507131      0x138E9FB       Neighborly text, "neighbor table dump requestbor table dump request"
20507189      0x138EA35       Neighborly text, "neighbor table dump request neighbor table dump request"
20507253      0x138EA75       Neighborly text, "neighbor table dump request"
20507288      0x138EA98       Neighborly text, "Neighbor entry is now dead"
20621466      0x13AA89A       LZMA compressed data, properties: 0x65, dictionary size: 0 bytes, uncompressed size: 2560 bytes
20628706      0x13AC4E2       Unix path: /var/run/rpcbind.sock
20651936      0x13B1FA0       Certificate in DER format (x509 v3), header length: 4, sequence length: 676
21857912      0x14D8678       Unix path: /dev/vc/0
22047096      0x1506978       Unix path: /sys/fs/xfs/stats/stats
22086088      0x15101C8       xz compressed data
22088354      0x1510AA2       Ubiquiti firmware header, third party, ~CRC32: 0x45430000, version: "STALE"
22194767      0x152AA4F       Unix path: /sys/kernel/debug/%pd/%s
22194830      0x152AA8E       Unix path: /sys/kernel/debug/%pd/%s
22194960      0x152AB10       Unix path: /sys/kernel/debug/%s
22339850      0x154E10A       Unix path: /sys/kernel/debug/dri.
22443304      0x1567528       Ubiquiti firmware additional data, name: _VA:, size: 1835363679 bytes, size2: 1634495599 bytes, CRC32: 0
22443320      0x1567538       Ubiquiti firmware additional data, name: _VA_FIXED:, size: 1920151399 bytes, size2: 1886728033 bytes, CRC32: 0
22531808      0x157CEE0       Ubiquiti firmware additional data, name: _DATA, size: 1163412803 bytes, size2: 1599491393 bytes, CRC32: 0
22531824      0x157CEF0       Ubiquiti firmware additional data, name: _STACK, size: 1163412803 bytes, size2: 1599229764 bytes, CRC32: 0
22531840      0x157CF00       Ubiquiti firmware additional data, name: _KMALLOC, size: 1163412803 bytes, size2: 1599427397 bytes, CRC32: 0
22531856      0x157CF10       Ubiquiti firmware additional data, name: _VMALLOC, size: 1163412803 bytes, size2: 1598969164 bytes, CRC32: 0
22531872      0x157CF20       Ubiquiti firmware additional data, name: _RODATA, size: 1094927173 bytes, size2: 1397972821 bytes, CRC32: 0
22584400      0x1589C50       Ubiquiti firmware additional data, name: UTE DEVICE DIAGNOSTIC, size: 1145372672 bytes, size2: 0 bytes, CRC32: 0
22648511      0x15996BF       Copyright string: "Copyright (C) 2021 Realtek NIC software team <nicfae@realtek.com> "
22712133      0x15A8F45       PARity archive data - Index file
22942399      0x15E12BF       Copyright string: "Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>"
22971339      0x15E83CB       Unix path: /sys/class/devcoredump start
22971459      0x15E8443       Unix path: /sys/class/devcoredump end
23009009      0x15F16F1       Copyright string: "Copyright(c) Pierre Ossman"
23068928      0x1600100       Unix path: /sys/firmware/devicetree/base
23072161      0x1600DA1       Unix path: /sys/firmware/fdt': CRC check failed
23110312      0x160A2A8       Unix path: /sys/kernel/debug/%pd/%s
23110367      0x160A2DF       Unix path: /sys/kernel/debug/%pd/%s
23110489      0x160A359       Unix path: /sys/kernel/debug/%s
23169625      0x1618A59       Neighborly text, "neighbor table overflow!app_solicit"
23217856      0x16246C0       Neighborly text, "NeighborSolicits"
23217880      0x16246D8       Neighborly text, "NeighborAdvertisementstMsgs"
23269565      0x16310BD       Neighborly text, "Neighbor"
23321923      0x163DD43       Neighborly text, "neighbor_results_rmap_lookup_le_range_result"
23321964      0x163DD6C       Neighborly text, "neighbor_resultokup_le_range"
23322107      0x163DDFB       Neighborly text, "neighbor_querys_rmap_update_error"
23322147      0x163DE23       Neighborly text, "neighbor_candidateror"
24811263      0x17A96FF       mcrypt 2.2 encrypted data, algorithm: blowfish-448, mode: CBC, keymode: 8bit
25355792      0x182E610       ASCII cpio archive (SVR4 with no CRC), file name: "dev", file name length: "0x00000004", file size: "0x00000000"
25355908      0x182E684       ASCII cpio archive (SVR4 with no CRC), file name: "dev/console", file name length: "0x0000000C", file size: "0x00000000"
25356032      0x182E700       ASCII cpio archive (SVR4 with no CRC), file name: "root", file name length: "0x00000005", file size: "0x00000000"
25356148      0x182E774       ASCII cpio archive (SVR4 with no CRC), file name: "TRAILER!!!", file name length: "0x0000000B", file size: "0x00000000"
30235648      0x1CD5C00       AES S-Box
30235904      0x1CD5D00       AES Inverse S-Box
33182367      0x1FA529F       mcrypt 2.2 encrypted data, algorithm: blowfish-448, mode: CBC, keymode: 8bit
33203367      0x1FAA4A7       mcrypt 2.2 encrypted data, algorithm: blowfish-448, mode: CBC, keymode: 8bit
33264007      0x1FB9187       mcrypt 2.2 encrypted data, algorithm: blowfish-448, mode: CBC, keymode: 8bit
33508798      0x1FF4DBE       MySQL ISAM compressed data file Version 4
33527808      0x1FF9800       Flattened device tree, size: 183425 bytes, version: 17

```


拆解boot.img

```shell
mkdir -p boot-unpack
dumpimage -i ${IMG} -T flat_dt  -p 0 boot-unpack/boot_fdt
ls -alh boot-unpack/boot_fdt

dumpimage -i ${IMG} -T flat_dt  -p 1 boot-unpack/boot_kernel
ls -alh boot-unpack/boot_kernel

dumpimage -i ${IMG} -T flat_dt  -p 2 boot-unpack/resource
ls -alh boot-unpack/boot_resource
```

构造boot.img

需要构造boot.its，里面记录了哪些内容用来合成boot.img

```shell
../rkbin/tools/mkimage -f boot.its -E -p 0x800 ../rockdev/boot.img
```


### boot.img类别三 标准Android bootimg

支持abootimg工具直接解压的boot.img属于标准Android bootimg

```shell
# file boot.img
boot.img: Android bootimg, kernel (0x10008000), ramdisk (0x11000000), second stage (0x10f00000), page size: 2048, cmdline (console=ttyFIQ0 firmware_class.path=/vendor/etc/firmware init=/init rootwait ro loop.max_part=7 androidboot.console=ttyFIQ0 and)
# binwalk boot.img

DECIMAL       HEXADECIMAL     DESCRIPTION
--------------------------------------------------------------------------------
0             0x0             Android bootimg, kernel size: 37586952 bytes, kernel addr: 0x10008000, ramdisk size: 1351182 bytes, ramdisk addr: 0x11000000, product name: ""
2048          0x800           Linux kernel ARM64 image, load offset: 0x0, image size: 38600704 bytes, little endian, 4k page size,
247488        0x3C6C0         SHA256 hash constants, little endian
20027392      0x1319800       ELF, 64-bit LSB shared object, version 1 (SYSV)
20031488      0x131A800       ELF, 32-bit LSB shared object, ARM, version 1 (SYSV)
20038336      0x131C2C0       SHA256 hash constants, little endian
20053872      0x131FF70       gzip compressed data, maximum compression, from Unix, last modified: 1970-01-01 00:00:00 (null date)
20095480      0x132A1F8       xz compressed data
24081080      0x16F72B8       DES SP2, little endian
24081592      0x16F74B8       DES SP1, little endian
24088576      0x16F9000       CRC32 polynomial table, little endian
25462342      0x1848646       Intel x86 or x64 microcode, sig 0x00000008, pf_mask 0x2000000, 2000-08-08, size 256
25462370      0x1848662       Intel x86 or x64 microcode, pf_mask 0x2000000, 2000-10-08, rev 0x0100, size 256
25477126      0x184C006       Intel x86 or x64 microcode, sig 0x00000008, pf_mask 0x2000000, 2000-08-08, size 256
25477154      0x184C022       Intel x86 or x64 microcode, pf_mask 0x2000000, 2000-10-08, rev 0x0100, size 256
25478198      0x184C436       Intel x86 or x64 microcode, sig 0x00000008, pf_mask 0x2000000, 2000-08-08, size 256
25478226      0x184C452       Intel x86 or x64 microcode, pf_mask 0x2000000, 2000-10-08, rev 0x0100, size 256
25479850      0x184CAAA       Intel x86 or x64 microcode, pf_mask 0x2000000, 2000-10-08, rev 0x0100, size 256
25480938      0x184CEEA       Intel x86 or x64 microcode, pf_mask 0x2000000, 2000-10-08, rev 0x0100, size 256
25481218      0x184D002       Intel x86 or x64 microcode, pf_mask 0x2000000, 2000-10-08, rev 0x0100, size 256
26093008      0x18E25D0       Neighborly text, "Neighbor entry is now deadaddress not specified"
26093385      0x18E2749       Neighborly text, "neighbor get requestrequest"
26093435      0x18E277B       Neighborly text, "neighbor get requestequest"
26093484      0x18E27AC       Neighborly text, "neighbor get requestget request"
26093538      0x18E27E2       Neighborly text, "neighbor get requestquest"
26093586      0x18E2812       Neighborly text, "neighbor get requestest"
26093632      0x18E2840       Neighborly text, "neighbor get requestnvalid values in header for neighbor dump request"
26093672      0x18E2868       Neighborly text, "neighbor dump requestp request"
26093723      0x18E289B       Neighborly text, "neighbor dump request request"
26093773      0x18E28CD       Neighborly text, "neighbor dump requestquest"
26093820      0x18E28FC       Neighborly text, "neighbor dump requestquest"
26093861      0x18E2925       Neighborly text, "neighbor table dump requestor table dump request"
26093918      0x18E295E       Neighborly text, "neighbor table dump requestor table dump request"
26093975      0x18E2997       Neighborly text, "neighbor table dump request"
26266822      0x190CCC6       Certificate in DER format (x509 v3), header length: 4, sequence length: 676
26499456      0x1945980       PGP RSA encrypted session key - keyid: 1C88D03 12C8F03 RSA (Encrypt or Sign) 1024b
29076326      0x1BBAB66       Unix path: /lib/firmware/5.10.160
29137599      0x1BC9ABF       Copyright string: "Copyright(c) Pierre Ossman"
29170628      0x1BD1BC4       Unix path: /lib/firmware/updates/5.10.160
29188204      0x1BD606C       Unix path: /sys/firmware/devicetree/base
29235797      0x1BE1A55       Unix path: /sys/firmware/fdt': CRC check failed
29237363      0x1BE2073       Unix path: /sys/kernel/debug/%s
29259545      0x1BE7719       Unix path: /sys/kernel/debug/dri.
29342130      0x1BFB9B2       Neighborly text, "NeighborSolicitsles.c"
29440243      0x1C138F3       Neighborly text, "neighbor table overflow!tx_compressed"
29480345      0x1C1D599       Copyright string: "Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>"
29541251      0x1C2C383       Neighborly text, "Neighbor, wdev(%u), cookie: %llu"
29732870      0x1C5B006       Unix path: /sys/kernel/debug/%pd/%s
29750868      0x1C5F654       Unix path: /sys/kernel/debug/%pd/%s
29838827      0x1C74DEB       Neighborly text, "NeighborAdvertisements hao: invalid header length: %u"
29935369      0x1C8C709       Unix path: /sys/kernel/debug/%pd/%s
30038220      0x1CA58CC       Neighborly text, "neighbor %.2x%.2x.%pM lostet/bridge/br_multicast.c"
30101520      0x1CB5010       Unix path: /sys/kernel/debug/%s
30118473      0x1CB9249       PARity archive data - file number 12370
30151295      0x1CC127F       Unix path: /sys/kernel/debug/%pd/%s
30362575      0x1CF4BCF       Unix path: /lib/firmware/updates
31491859      0x1E08713       MySQL ISAM compressed data file Version 5
33016039      0x1F7C8E7       mcrypt 2.2 encrypted data, algorithm: blowfish-448, mode: CBC, keymode: 8bit
33101468      0x1F9169C       ASCII cpio archive (SVR4 with no CRC), file name: "dev", file name length: "0x00000004", file size: "0x00000000"
33101584      0x1F91710       ASCII cpio archive (SVR4 with no CRC), file name: "dev/console", file name length: "0x0000000C", file size: "0x00000000"
33101708      0x1F9178C       ASCII cpio archive (SVR4 with no CRC), file name: "root", file name length: "0x00000005", file size: "0x00000000"
33101824      0x1F91800       ASCII cpio archive (SVR4 with no CRC), file name: "TRAILER!!!", file name length: "0x0000000B", file size: "0x00000000"
33328896      0x1FC8F00       AES S-Box
33329152      0x1FC9000       AES Inverse S-Box
33352808      0x1FCEC68       Intel x86 or x64 microcode, sig 0xffffffc0, pf_mask 0x00, 1B1C-09-03, size 2048
37591040      0x23D9800       gzip compressed data, from Unix, last modified: 1970-01-01 00:00:00 (null date)
38945792      0x2524400       Flattened device tree, size: 276646 bytes, version: 17
39222784      0x2567E00       PC bitmap, Windows 3.x format,, 220 x 110 x 8
39229952      0x2569A00       PC bitmap, Windows 3.x format,, 654 x 270 x 8
39408128      0x2595200       PC bitmap, Windows 3.x format,, 654 x 270 x 8
39586304      0x25C0A00       PC bitmap, Windows 3.x format,, 220 x 110 x 8
39593984      0x25C2800       Flattened device tree, size: 276646 bytes, version: 17
```

拆解方法：

```shell
# abootimg -x boot.img
writing boot image config in bootimg.cfg
extracting kernel in zImage
extracting ramdisk in initrd.img
extracting second stage image in stage2.img
```

构造方法：

```shell
# abootimg --create boot.img \
    -f bootimg.cfg \
    -k zImage \
    -r initrd.img \
    -s stage2.img 
reading config file bootimg.cfg
reading kernel from zImage
reading ramdisk from initrd.img
reading second stage from stage2.img
Writing Boot Image boot.img
# ls -alh
total 76M
drwxr-xr-x 2 root root 4.0K Jun 24 22:40 .
drwxr-xr-x 6 root root 4.0K Jun 24 22:39 ..
-rw-r--r-- 1 root root  39M Jun 24 22:40 boot.img
-rw-r--r-- 1 root root  429 Jun 24 22:39 bootimg.cfg
-rw-r--r-- 1 root root 1.3M Jun 24 22:39 initrd.img
-rw-r--r-- 1 root root 635K Jun 24 22:39 stage2.img
-rw-r--r-- 1 root root  36M Jun 24 22:39 zImage
```




---
