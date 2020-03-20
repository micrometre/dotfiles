#lxd api openssl config
lxd-api () {
lxc config set core.https_address "[::]:8443"
lxc config set core.trust_password password
openssl req -x509 -newkey rsa:2048 -keyout ~/.config/lxc/client.key.secure -out ~/.config/lxc/client.crt -days 3650
openssl rsa -in ~/.config/lxc/client.key.secure -out ~/.config/lxc/client.key
lxc config trust add ~/.config/lxc/client.crt
curl -s -k --cert ~/.config/lxc/client.crt --key ~/.config/lxc/client.key https://127.0.0.1:8443/1.0 | jq .metadata.auth
curl -s --unix-socket /var/lib/lxd/unix.socket a/1.0 | jq .
}
#work around snap lxd unix.socket issue
lxd-mount () {
sudo mkdir /var/lib/lxd
sudo mount -o bind /var/snap/lxd/common/lxd/ /var/lib/lxd
}
#get lxd running containers ip
lxd-ip () {
lxd_if2=$(lxc list | awk '{ print $2, $6}' | xargs | awk '{print $3, $4}')
echo $lxd_if2
}
#login to lxd container
lxd-login ()
{
containername="$1"
lxc exec "$1" -- sudo --login --user ubuntu
}
#push folder to lxd container
lxd-folder ()
{
source_folder="$1"
container_name="$2"
tar cf - $1 | lxc exec $2 -- tar xvf - -C /home/ubuntu
}

#push file to lxd container
lxd-file ()
{
source_folder="$1"
container_name="$2"
lxc file push $1 $2/home/ubuntu/ 
}

#stop all contaners
lxd-stop ()
{
lxc list | awk '{print $2}' | xargs | cut -c 5- | xargs lxc stop
}
#delete all contaners
lxd-delete()
{
lxc list | awk '{print $2}' | xargs | cut -c 5- | xargs lxc delete
}
