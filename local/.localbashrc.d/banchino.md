VM=10.3.12.122
VMUSER=ubuntu
WIN=172.16.99.102

unitec-mon: 10.3.12.122

# windows rdesktop tunnel
ssh -L "3389:$WIN:3389" "$VM" -l "$VMUSER" -N

# DBCN/DBIO's tunnels
ssh -L 22101:172.16.100.1:22 10.3.12.122 -l ubuntu -N &
ssh -L 22102:172.16.2.1:22 10.3.12.122 -l ubuntu -N &
ssh -L 22103:172.16.3.1:22 10.3.12.122 -l ubuntu -N &
ssh -L 22104:172.16.4.1:22 10.3.12.122 -l ubuntu -N &

# dbcn 
ssh -p 22101 root@localhost systemctl stop cnd
ssh -p 22101 root@localhost mount -o remount,rw / 
scp -P 22101 ./cmd/cnd/cnd root@localhost:/usr/local/bin/
ssh -p 22101 root@localhost mount -o remount,ro / 
ssh -p 22101 root@localhost systemctl start cnd

# iod 1
ssh -p 22102 root@localhost systemctl stop iod
ssh -p 22102 root@localhost mount -o remount,rw / 
scp -P 22102 ./cmd/iod/iod root@localhost:/usr/local/bin/
ssh -p 22102 root@localhost mount -o remount,ro / 
ssh -p 22102 root@localhost systemctl start iod

# iod 2
ssh -p 22103 root@localhost systemctl stop iod
ssh -p 22103 root@localhost mount -o remount,rw / 
scp -P 22103 ./cmd/iod/iod root@localhost:/usr/local/bin/
ssh -p 22103 root@localhost mount -o remount,ro / 
ssh -p 22103 root@localhost systemctl start iod

# iod 3
ssh -p 22104 root@localhost systemctl stop iod
ssh -p 22104 root@localhost mount -o remount,rw / 
scp -P 22104 ./cmd/iod/iod root@localhost:/usr/local/bin/
ssh -p 22104 root@localhost mount -o remount,ro / 
ssh -p 22104 root@localhost systemctl start iod

# check status dbcn and dbio's
ssh -p 22101 root@localhost systemctl status cnd
ssh -p 22102 root@localhost systemctl status iod
ssh -p 22103 root@localhost systemctl status iod
ssh -p 22104 root@localhost systemctl status iod

