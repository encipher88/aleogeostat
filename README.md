# aleogeostat

This location monitoring allows you to determine the decentralization of the blockchain and / or indicate its absence, statistics are compiled on validators: providers, cities and countries, and a map of validators is also built

## 1. Set up your server or home PC. Install UBUNTU 20.04.

## 2. GET your $TOKEN to access IP CHECKER.

1. GO to https://ipinfo.io/

![1](https://user-images.githubusercontent.com/36136421/214031958-66e3a34b-bea3-41ef-80e7-fb2c2c62742b.png)

2. Sign up 

![2](https://user-images.githubusercontent.com/36136421/214031974-361c58cd-f11e-4734-b905-34b46b137c0a.png)

3. Copy this TOKEN

![3](https://user-images.githubusercontent.com/36136421/214031979-55d97fdf-7e71-4b15-ab7e-c5f0eb1c961c.png)

## 3. Run service in TMUX

Install and run tmux
```bash
cd $HOME && sudo apt update && sudo apt upgrade -y && sudo apt install tmux bash git curl -y && tmux
```
RUN SCRIPT
```bash
cd $HOME && rm -rf aleogeostat && git clone https://github.com/encipher88/aleogeostat.git && cd aleogeostat && chmod +x ippars.sh && bash ippars.sh
```
This script make all automatically 

Input your token and press ENTER

![Screenshot_1](https://user-images.githubusercontent.com/36136421/214033681-7feb3921-35c4-4909-a212-f59e87dba18f.png)

MAP result

![Screenshot_2](https://user-images.githubusercontent.com/36136421/214033748-7b60b44c-171d-4f80-aec7-d650da6e470a.png)

![Screenshot_6](https://user-images.githubusercontent.com/36136421/214036297-b347c3eb-1c83-450c-a327-8f3ced8ee966.png)

Statistic result!

![Screenshot_3](https://user-images.githubusercontent.com/36136421/214033816-46c8fcc7-ec0a-44c8-a813-bbe8ca60f3d2.png)

PATH to FILES

![Screenshot_5](https://user-images.githubusercontent.com/36136421/214036377-7ff838ed-df7c-4f10-af73-da3c2535bba3.png)
