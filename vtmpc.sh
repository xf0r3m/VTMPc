#!/bin/bash

# Usage: ./vtmpc.sh createvm name ostype memory network disk [dvddrive]
# Usage: ./vtmpc.sh getvm ubuntu:18.04

vtmp_server="vtmp.morketsmerke.net";

function getOstypes {

	if [ "$(which vboxmanage)" ]; then 
		types=$(vboxmanage list ostypes | grep "^ID: " | awk '{printf $2" "}');

		for ostype in $types; do
			number=$(vboxmanage list ostypes | grep -n "^ID:.*$ostype$" | sed -n '1p' | cut -d ":" -f 1);
			number=$((number + 1));
			desc=$(vboxmanage list ostypes | sed -n "${number}p" | cut -d " " -f 2-);
			echo -e "${ostype}\t\t${desc}";
		done
	fi

}

function printHelp {

	echo "VTMPc - klient VTMP";
	echo "morketsmerke.net";
	echo "Copyleft. All right reversed 2021";
	echo;
	echo "# Użycie: ./vtmpc.sh createvm <name> <ostype> <memory> <network> <1-n>  <disk> [dvddrive]";
	echo "# Użycie: ./vtmpc.sh getvm <oznaczenie_dla_vtmpc / adres_www> ";
	echo "# Użycie: ./vtmpc.sh findmedium <oznaczenie_dla_vtmpc / adres_www> ";
	echo "# Użycie: ./vtmpc.sh export <name> <targetpath> [annotation]";
	echo;
	echo "Wyjaśnie parametrów dla opcji 'createvm' - Tworzenie nowej maszyny wirtualnej:";
	echo -e "\t<name>  \t\t\tNazwa maszyny wirtualnej np \"Ubuntu 20.10 desktop\". Przy nazwa wielwyrazowych należy pamiętać o apostrofach";
	echo -e "\t<ostype> \t\t\tSystem operacyjny na maszynie, lista oznaczeń systemów, poniżej w sekcji: Wspierane systemy operacyjne.";
	echo -e "\t<memory> \t\t\tIlość przydzielanej pamięci RAM.";
	echo -e "\t<network>\t\t\tTyp sieci na karcie, do wyboru: nat, bridged, intnet. Rozwinięcie sekcji Rodzaje sieci";
	echo -e "\t<1-n>    \t\t\tNumer karty sieciowej maszyny.";
	echo -e "\t<dysk>   \t\t\tDysk maszyny może być: oznaczeniem VTMPc, adresem WWW, lub liczbą. Przy innych wartościach niż liczby dysk zostanie"
	echo -e "\t\t\t\t\tpobrany z sieci VTMP badź dowolnego serwera WWW. Przy podaniu liczby zostanie utworzony pusty dysk wielkości podanej w MB";
	echo -e "\t[dvddrive]\t\t\tOpcjonalna ścieżka do obrazu płyty dla tworzenia maszyn z czystymi, nowymi dyskami";
	echo;
	echo "Wyjasnianie parameterów dla opcji 'getvm' - pobranie oraz import maszyny z serwera:";
	echo -e "\t<oznacznie_dla_vtmpc / adres_www>\tOznaczenia dla VTMPc, są dość intuicyjne: <nazwa_systemu>/<wersja>/<architektura / przeznaczenie>";
	echo -e "\t\t\t\t\t\tDla windows server np: windows/2012r2/amd64, dla Ubuntu Linux: ubuntu/20.10/desktop. Oznacznia znajdują się w postach na";
	echo -e "\t\t\t\t\t\tstronie: https://vtmp.morketsmerke.net.";
	echo -e "\t[autostart]\t\t\t\tParametr opcjonalny. Uruchamia maszynę zaraz po jej zaimportowaniu.";
	echo;
	echo "Wyjaśnienie parametrów dla opcji 'findmedium' - sprawdzenie dostępności plików maszyny na serwerze:";
	echo -e "\t<oznaczenie_dla_vtmpc / adres_www>\tOznaczenie dla VTMPc. Wyjaśnione powyżej.";
	echo;
	echo "Rodzaje sieci:";
	echo -e "\tbridged 1 enp1s0\t\tPo ustawieniu rodzaju sieci na 'bridged', po numerze karty podajemy interfejs, na który ma być mostkowana maszyna";
	echo -e "\tintnet 1 netname\t\tPo ustawieniu rodzaju sieci na 'intnet', po numerze karty podajemy nazwę sieci wewnętrznej";
	echo;
	echo "Wyjaśnienie argumentów dla opcji 'export' - eksport maszyny z wytycznymi VTMP2.0: ";
	echo;
	echo -e "\t<name>   \t\t\tNazwa maszyny wirtualnej, pobrana z polecenia vboxmanage list vms.";
	echo -e "\t<targetpath>   \t\t\tŚcieżka docelowa dla eksportowanej maszyny.";
	echo -e "\t[annotation]   \t\t\tInformacja o SSH + adnotacje.";
	echo;
	echo "Wspierane systemy operacyjne:";
	getOstypes;

}

if [ ! "$(which vboxmanage)" ]; then echo "[-] Nie znaleziono Virtualbox w systemie"; exit 1; fi 

if [ "$1" ]; then 

	if [ "$1" = "createvm" ]; then

		flag_USERINPUTVALIDITY=0;
		echo "[*] Tworzenie maszyny wirtualnej";

		if [ ! "$2" ]; then flag_USERINPUTVALIDITY=1; fi

		if [ "$3" ]; then 
			ostypes=$(vboxmanage list ostypes | grep '^ID: ' | awk '{printf $2" "}');
			if ! echo $ostypes | grep -q "$3" ; then flag_USERINPUTVALIDITY=1; fi
		else
			flag_USERINPUTVALIDITY=1;
		fi

		if [ "$4" ]; then 

			if ! echo "$4" | grep -q "[0-9]*" ; then flag_USERINPUTVALDITY=1; fi
		else
			flag_USERINPUTVALIDITY=1;
		fi

		if [ "$5" ]; then 
			if [[ ! "$5" =~ ^(nat|bridged|intent)$ ]]; then flag_USERINPUTVALIDITY=1; fi
		else
			flag_USERINPUTVALIDITY=1;
		fi

		if [ "$6" ]; then
			if echo "$6" | grep -q "[0-9]*" ; then flag_USERINPUTVALIDITY=0; fi
		else
			flag_USERINPUTVALIDITY=1;
		fi

		case $5 in
			'bridged') if [ "$7" ]; then
					if ! ip a | grep -qo "$7" ; then
						flag_USERINPUTVALIDITY=1;
					fi
				else
					flag_USERINPUTVALIDITY=1;
				fi;;
			'intnet') if [ "$7" ]; then
					if echo $7 | grep -q '^.*\/.*/desktop\|server\|amd64\|x86$' ; then
						flag_USERINPUTVALIDITY=1;
					fi
				else
					flag_USERINPUTVALIDITY=1;
				fi;;
			'nat') flag_USERINPUTVALIDITY=$flag_USERINPUTVALIDITY;;
			*) flag_USERINPUTVALIDITY=1;
		esac


		if [ "$8" ]; then 
			if [ "$5" = "nat" ]; then disk=$7; dvddrive=$8;
			else disk=$8; dvddrive=$9; fi
		else
			disk=$7;
			dvddrive=$8;
		fi

		if [ "$disk" ]; then 
			if ! echo "$disk" | grep -q '^.*\/.*\/desktop\|server\|amd64\|x86$' ; then
				if ! echo "$disk" | grep -q '[0-9]*' ; then 
					flag_USERINPUTVALIDITY=1; 
				fi
			fi
		else
			flag_USERINPUTVALIDITY=1;
		fi

		if [ "$9" ]; then
			if [ ! -f "$9" ]; then flag_USERINPUTVALIDITY=1; 
			else dvddrive=$9;
			fi

		fi

		if [ "$flag_USERINPUTVALIDITY" -eq 1 ]; then
			printHelp;
			exit 1;
		fi


		if echo $disk | grep -q '^.*\/.*\/desktop\|server\|amd64\|x86$' ; then
			if echo $disk | grep -q 'http'; then 
				diskLink=$disk;
			else
				diskFile="$(echo $disk | sed -e 's/\//_/g' -e 's/\.//g')-disk001.vmdk";
				diskLink="http://$vtmp_server/vms/$disk/$diskFile";
				wget --no-cache --spider -q $diskLink;
			       	if [ $? -ne 0 ]; then 
					echo "[-] Nie znaleziono dysku o podanym oznaczeniu. Tworznie maszyny zakończone.";
					exit 1;
				fi
			fi
		else
			diskLink=$disk;
		fi

		#Utworzenie i rejestracja maszyny
		echo "vboxmanage createvm --name $2 --ostype $3 --register";
		vboxmanage createvm --name "$2" --ostype $3 --register;
		#Ustawienie odpowiedniej ilości pamięci
		echo "vboxmanage modifyvm $2 --memory $4";
		vboxmanage modifyvm "$2" --memory $4
		#Ustawieniae odpowiednich ustawień sieciowych
		echo "vboxmanage modifyvm $2 --nic$6 $5";
		vboxmanage modifyvm "$2" --nic$6 $5;
		case "$5" in 
			'bridged') hostadapter=$7;
					echo "vboxmanage modifyvm $2 --bridgeadapter$6 $hostadapter";
					vboxmanage modifyvm "$2" --bridgeadapter$6 $hostadapter;;
			'intnet') intnetname=$7;
					echo "vboxmanage modifyvm $2 --intnet$6 $intnetname";
					vboxmanage modifyvm "$2" --intnet$6 $intnetname;;
		esac
		
		#Dodanie do maszyny kontrolera dysków
		echo "vboxmanage storagectl $2 --name SATA0 --add sata";
		vboxmanage storagectl "$2" --name SATA0 --add sata;
		if echo $diskLink | grep -q 'http'; then
			#Pobranie dysku z internetu
			echo "wget $diskLink -O ~/VirtualBox\ VMs/$2/${2}-disk001.vmdk";
			wget $diskLink -O "$HOME/VirtualBox VMs/$2/${2}-disk001.vmdk";
			#Dołącznie pobranego dysku do maszyny
			echo "vboxmanage storageattach $2 --storagectl SATA0 --port 0 --type hdd --medium $HOME/VirtualBox\ VMs/$2/${2}-disk001.vmdk";
			vboxmanage storageattach "$2" --storagectl SATA0 --port 0 --type hdd --medium "$HOME/VirtualBox VMs/$2/${2}-disk001.vmdk";
		else
			#Utworzenie nowego dysku o podanej wielkości 
			echo "vboxmanage createhd --filename $HOME/VirtualBox\ VMs/$2/${2}.vdi --size $diskLink --format vdi --variant standard";
			vboxmanage createhd --filename "$HOME/VirtualBox VMs/$2/${2}.vdi" --size $diskLink --format vdi --variant standard;
			#Dołączenie nowo utworzonego dysku do maszyny
			echo "vboxmanage storageattach $2 --storagectl SATA0 --port 0 --type hdd --medium $HOME/VirtualBox\ VMs/$2/${2}.vdi";
			vboxmanage storageattach "$2" --storagectl SATA0 --port 0 --type hdd --medium "$HOME/VirtualBox VMs/$2/${2}.vdi";
		fi
		#Sprawdzenie czy dołączono obraz z systemem pod czas tworzenia maszyny
		if [ "$dvddrive" ]; then 
			#Dołączenie obrazu do maszyny
			echo "vboxmanage storageattach $2 --storagectl SATA0 --port 1 --type dvddrive --medium $dvddrive";
			vboxmanage storageattach "$2" --storagectl SATA0 --port 1 --type dvddrive --medium $dvddrive;
		fi

		echo "[?] Jeśli wszystkie polecenie zakończyły się pomyślnie możesz uruchmiać nowoutworzoną maszynę wirtualną";

	elif [ "$1" = "getvm" ]; then

		if [ "$2" ]; then
			machineId=$2;

			if ! echo "$machineId" | grep -q ".*\/.*\/desktop\|server\|amd64\|x86\|" ; then 
				printHelp;
				exit 1;
			fi

			echo "[*] Importowanie maszyny: $machineId";
			if echo "$machineId" | grep -q ".*\/.*\/desktop\|server\|amd64\|x86\|" ; then
				machineFilename="$(echo $machineId | sed -e 's/\//_/g' -e 's/\.//g').ova";
				vmLink="http://$vtmp_server/vms/$machineId/$machineFilename";
				wget --no-cache --spider -q $vmLink;
				if [ $? -eq 0 ]; then 
					wget $vmLink -O "$HOME/VirtualBox VMs/$machineFilename";
					vboxmanage import "$HOME/VirtualBox VMs/$machineFilename";
				else
					if echo "$machineId" | grep -q 'http' ; then 
						vmLink=$machineId;
						machineFilename=$(echo $vmLink | awk 'BEGIN{FS="/"}{printf $NF}');
						wget $vmLink -O "$HOME/VirtualBox VMs/$machineFilename";
						vboxmanage import "$HOME/VirtualBox VMs/$machineFilename";
					else
						echo "[-] Nie znaleziono maszyny o podanym oznaczeniu. Importowanie maszyny zakończone.";
						exit 1;
					fi
				fi
			else
				printHelp;
				exit 1;
			fi

			if [ "$3" ] && [ "$3" = "autostart" ]; then
				lastAddedVm=$(vboxmanage list vms | tail -n 1 | awk '{printf $1}' | sed 's/"//g');
				vboxmanage startvm "$lastAddedVm";
			fi		
		else
			printHelp;
			exit 1;
		fi
	elif [ "$1" = "findmedium" ]; then
		sign=$2;
		if echo $sign | grep -q '^.*\/.*\/desktop\|server\|amd64\|x86' ; then
			if echo $sign | grep -q 'http'; then
				mediumLink=$sign;
			else
				mediumList[0]="$(echo $sign | sed -e 's/\//_/g' -e 's/\.//g').ova";
				mediumList[1]="$(echo $sign | sed -e 's/\//_/g' -e's/\.//g')-disk001.vmdk";
			fi
			if [ "$mediumLink" ]; then 
				wget --no-cache --spider -q $mediumLink;
				if [ $? -eq 0 ]; then 
					echo "[+] Podane medium jest dostępne na serwerze";
				else
					echo "[-] Nie znaleziono podanego medium na serwerze VTMP";
				fi
			else
				for medium in ${mediumList[*]}; do 
					mediumLink="http://$vtmp_server/vms/$sign/$medium";
					wget --no-cache --spider -q $mediumLink;
					if [ $? -eq 0 ]; then
						echo "[+] Medium: $sign = $medium . Jest dostępne na serwerze.";
					else 
						echo "[-] Medium: $sign = $medium . Nie jest dostępne na serwerze."; 
					fi

				done
			fi
		else
			printHelp;
			exit 1;
		fi
 	elif [ "$1" = "export" ]; then
		
		if [ "$2" ]; then vmname=$2;
		else printHelp; exit 1;
		fi

		if [ "$3" ]; then targetPath=$3;
		else printHelp; exit 1;
		fi

		if [ "$4" ]; then 
			annotation=$4
		fi

		if vboxmanage showvminfo "$vmname" > /dev/null 2>&1 ; then 

			whitespaceCount=$(vboxmanage showvminfo "$vmname" | grep "Name: " | grep -o '\ ' | grep -n "." | tail -n 1 | cut -d ":" -f 1);

			if [ $whitespaceCount -le 26 ]; then

				name=$(vboxmanage showvminfo "$vmname" | grep "Name: " | awk '{printf $2" "$3" "$4}');
				osname=$(echo $name | cut -d " " -f 1);
				version=$(echo $name | cut -d " " -f 2);
				arch=$(echo $name | cut -d " " -f 3);
				vtmpc=$(echo $name | tr [:upper:] [:lower:] |sed 's@ @/@g');

			elif [ $whitespaceCount -eq 27 ]; then 

				name=$(vboxmanage showvminfo "$vmname" | grep "Name: " | awk '{printf $2" "$3" "$4" "$5}');
				osname=$(echo $name | cut -d " " -f 1-2);
				version=$(echo $name | cut -d " " -f 3);
				arch=$(echo $name | cut -d " " -f 4);
				vtmpc=$(echo $name | tr [:upper:] [:lower:] | sed -e 's/ /_/' -e 's@ @/@g');

			else
				echo "Nazwa niezgodna z konwencją VTMP, tchórzliwie odmawiam wykonania zadania";
				exit 1;

			fi

			configFile=$(vboxmanage showvminfo "$vmname" | grep "Config file: " | awk '{ for (i=3; i<=NF; i++) printf $i" "; }' | sed 's/[[:space:]]$//');
			ostype=$(grep "<Machine" "$configFile" | cut -d '"' -f 6);

			echo "[*] Eksportowanie maszyny wirtualnej.";

			echo "Nazwa: $name";
			echo "Nazwa OS: $osname";
			echo "Wersja: $version";
			echo "Architektura: $arch";
			echo "VTMPc: $vtmpc";
			echo "OSType: $ostype";
			ovaname=$(echo $vmname | tr [:upper:] [:lower:] | sed -e 's/\ /_/g' -e 's/\.//g');
			ovaname=$(echo "${ovaname}.ova");
			echo "Nazwa pliku: $ovaname";

			if [ -d "$targetPath" ]; then 

				mkdir -p ${targetPath}/$vtmpc;

				echo "vboxmanage export \"$vmname\" -o ${targetPath}/${vtmpc}/${ovaname} --vsys 0 --product $osname --version $version --description \"${arch};${annotation}\" --producturl $vtmpc --vendor $ostype";

				vboxmanage export "$vmname" -o ${targetPath}/${vtmpc}/$ovaname --vsys 0 --product "$osname" --version "$version" --description "${arch};${annotation}" --producturl "$vtmpc" --vendor "$ostype";
				echo "[*] Rozpakowywanie plików maszyny";
				tar -xvf ${targetPath}/${vtmpc}/$ovaname -C ${targetPath}/${vtmpc};

			else 
				echo "Nie odnaleziono ścieżki docelowej";
				exit 1;
			fi

		else
			echo "Nie odnaleziono maszyny";
			exit 1;

		fi			
	else
		printHelp;
		exit 1;
	fi

else
	printHelp;
	exit 1;

fi
