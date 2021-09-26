# VTMPc - klient VTMP
## morketsmerke.net ® 2020

Wraz z VTMP powstał klient, który ułatwi nam tworzenie maszyn virtualnych za pomocą polecenia vboxmanage. Podczas tworzenia maszyn ustawiamy nazwę, rodzaj systemu operacyjnego, ilość pamięć RAM,  ustawienia karty sieciowej  a zamiast podawać wiekość dysku w MB możemy wykorzstać udostępnione tutaj dyski. Ostatnim opcjonalnym parametrem jest obraz płyty. Po za ustawieniem wymienionych tutaj wartości, tworzenie maszyny odbywa się automatycznie, sprowadzając tę czynność do wydajania jedngo polenia. Śmiem twierdzić że szybko piszący użytkownicy utworzą maszynę szybciej przez VTMPc niż kikając przez GUI. Tworzenie maszyn jest tylko dodatkiem. Przy tworznie VTMPc, główna myśl koncetrowała się wokół pobierania już gotowych maszyn, dlatego też w postach maszyn znajdują się pole "VTMPc", zawiera ono oznaczenie danej maszyny aby skrypt mógł się odwołać. Oznaczenia zawyczaj zawiera nazwe dystrybucji wersję oraz architekturę lub przeznaczenie dystrybucji. Dla systemów, które występują tylko w jednej archtekturze w oznaczenia pozostaje ona zapisana aby być zgodna ze wzorcem wyrażenia dla oznaczenia. VTMPc posiada tylko dwie opcje wspomniane wcześniej tworzenie maszyn oraz pobieranie ich z serwera VTMP do pobrania maszyny klientowi wystarczy poprawne oznaczenie.

### Instalacja na systemach Linux:

1. ```$ git clone https://git.morketsmerke.net/xf0r3m/vtmpc.git```
2. ```$ cd vtmpc```
3. ```$ chmod +x vtmpc```
4. [opcjonalnie] ```$ sudo cp vtmpc /usr/local/bin```
5. [opcjonalnie] ```Restarturjemy powłokę```
6. ```$ vtmpc```

### Instalacja na systemach Windows:


1. Ściągamy paczkę z repozytotium: https://git.morketsmerke.net/xf0r3m/VTMPc/archive/master.zip
2. Paczkę wypakowywujemy na katalogu domowym użytkownika (np. C:\Users\Admin).
3. Pobieramy i instalujemy Git dla Windows: https://github.com/git-for-windows/git/releases/download/v2.29.2.windows.2/Git-2.29.2.2-64-bit.exe

4. Po zainstalowaniu Git, otwieramy plik C:/Program Files/Git/etc/bash.bashrc, dopisujemy w nim poniższe linie:
         export PATH=${PATH}:/c/Program\ Files/Oracle/VirtualBox:/c/Users/<użytkownik>/vtmpc
    	 alias vboxmanage='VBoxManage.exe'
    	 alias vtmpc='vtmpc.sh'

5. Plik zapisujemy na swoim katalogu domowym pod nazwą '.bashrc'. Otwieramy Git Bash. Jest prawdobobne że przed pojawieniem się znaku zachęty zostanie wyświetlony komunikat o tym że znaleziono pliku .bashrc ale nie znaleziono pliku .bash_profile, który uruchamia .bashrc i że plik .bash_profile został utworzony przez powłokę. Uruchamiamy ponownie Git Bash.

6. Jeśli polecenie vboxmanage jest osiągalne poprzez zapisanie 'vbox' i naciśniecie klawisza 'Tab', oznacza to że wszystkie wymagania zostały spełnione. Jeśli polecenie nie jest osiągalne upewnij się że masz zainstalowany VirtualBox w systemie.

7. Nadajemy prawo do wykoania dla pliku vtmpc.sh: ```$ chmod +x vtmpc.sh.```

8. Teraz możemy już uruchamiać naszego klienta. ```$ vtmpc```

### Użycie:

```
VTMPc - klient VTMP
morketsmerke.net ® 2020

# Użycie: ./vtmpc.sh createvm <name> <ostype> <memory> <network> <1-n>  <disk> [dvddrive]
# Użycie: ./vtmpc.sh getvm <oznaczenie_dla_vtmpc / adres_www> 
# Użycie: ./vtmpc.sh findmedium <oznaczenie_dla_vtmpc / adres_www> 
# Użycie: ./vtmpc.sh export <name> <targetpath> [annotation]

Wyjaśnie parametrów dla opcji 'createvm' - Tworzenie nowej maszyny wirtualnej:
	<name> 	 	Nazwa maszyny wirtualnej np "Ubuntu 20.10 desktop". Przy nazwa wielwyrazowych należy pamiętać o apostrofach
	<ostype> 	System operacyjny na maszynie, lista oznaczeń systemów, poniżej w sekcji: Wspierane systemy operacyjne.
	<memory> 	Ilość przydzielanej pamięci RAM.
	<network>	Typ sieci na karcie, do wyboru: nat, bridged, intnet. Rozwinięcie sekcji Rodzaje sieci
	<1-n>    	Numer karty sieciowej maszyny.
	<dysk>   	Dysk maszyny może być: oznaczeniem VTMPc, adresem WWW, lub liczbą. Przy innych wartościach niż liczby dysk zostanie pobrany z sieci VTMP badź dowolnego serwera WWW. Przy podaniu liczby zostanie utworzony pusty dysk wielkości podanej w MB
	[dvddrive]	Opcjonalna ścieżka do obrazu płyty dla tworzenia maszyn z czystymi, nowymi dyskami

Wyjasnianie parameterów dla opcji 'getvm' - pobranie oraz import maszyny z serwera:
	<oznacznie_dla_vtmpc 
	/ adres_www>	Oznaczenia dla VTMPc, są dość intuicyjne: <nazwa_systemu>/<wersja>/<architektura / przeznaczenie> 
			Dla windows server np: windows/2012r2/amd64, 
			dla Ubuntu Linux: ubuntu/20.10/desktop. 
			Oznacznia znajdują się w postach na stronie: https://vtmp.morketsmerke.net.
	[autostart]	Parametr opcjonalny. Uruchamia maszynę zaraz po jej zaimportowaniu.

Wyjaśnienie parametrów dla opcji 'findmedium' - sprawdzenie dostępności plików maszyny na serwerze:
	<oznaczenie_dla_vtmpc 
	/ adres_www>	Oznaczenie dla VTMPc. Wyjaśnione powyżej.

Rodzaje sieci:
	bridged 1 enp1s0	Po ustawieniu rodzaju sieci na 'bridged', 
				po numerze karty podajemy interfejs, na który ma być mostkowana maszyna
	intnet 1 netname	Po ustawieniu rodzaju sieci na 'intnet', 
				po numerze karty podajemy nazwę sieci wewnętrznej

Wyjaśnianie paramentrów dla opcji 'export' - export maszyny z wytycznymi VTMP2.0:

	<name>			Nazwa maszyny wirtualnej, pobrana z polecenia vboxmanage list vms.
	<targetpath>		Ścieżka docelowa dla eksportowanej maszyny.
	[annotation]		Informacja o SSH + adnotacje.

Wspierane systemy operacyjne:
Other		Other/Unknown
Other_64		Other/Unknown (64-bit)
Windows31		Windows 3.1
Windows95		Windows 95
Windows98		Windows 98
WindowsMe		Windows ME
WindowsNT3x		Windows NT 3.x
WindowsNT4		Windows NT 4
Windows2000		Windows 2000
WindowsXP		Windows XP (32-bit)
WindowsXP_64		Windows XP (64-bit)
Windows2003		Windows 2003 (32-bit)
Windows2003_64		Windows 2003 (64-bit)
WindowsVista		Windows Vista (32-bit)
WindowsVista_64		Windows Vista (64-bit)
Windows2008		Windows 2008 (32-bit)
Windows2008_64		Windows 2008 (64-bit)
Windows7		Windows 7 (32-bit)
Windows7_64		Windows 7 (64-bit)
Windows8		Windows 8 (32-bit)
Windows8_64		Windows 8 (64-bit)
Windows81		Windows 8.1 (32-bit)
Windows81_64		Windows 8.1 (64-bit)
Windows2012_64		Windows 2012 (64-bit)
Windows10		Windows 10 (32-bit)
Windows10_64		Windows 10 (64-bit)
Windows2016_64		Windows 2016 (64-bit)
Windows2019_64		Windows 2019 (64-bit)
WindowsNT		Other Windows (32-bit)
WindowsNT_64		Other Windows (64-bit)
Linux22		Linux 2.2
Linux24		Linux 2.4 (32-bit)
Linux24_64		Linux 2.4 (64-bit)
Linux26		Linux 2.6 / 3.x / 4.x (32-bit)
Linux26_64		Linux 2.6 / 3.x / 4.x (64-bit)
ArchLinux		Arch Linux (32-bit)
ArchLinux_64		Arch Linux (64-bit)
Debian		Debian (32-bit)
Debian_64		Debian (64-bit)
Fedora		Fedora (32-bit)
Fedora_64		Fedora (64-bit)
Gentoo		Gentoo (32-bit)
Gentoo_64		Gentoo (64-bit)
Mandriva		Mandriva (32-bit)
Mandriva_64		Mandriva (64-bit)
Oracle		Oracle (32-bit)
Oracle_64		Oracle (64-bit)
RedHat		Red Hat (32-bit)
RedHat_64		Red Hat (64-bit)
OpenSUSE		openSUSE (32-bit)
OpenSUSE_64		openSUSE (64-bit)
Turbolinux		Turbolinux (32-bit)
Turbolinux_64		Turbolinux (64-bit)
Ubuntu		Ubuntu (32-bit)
Ubuntu_64		Ubuntu (64-bit)
Xandros		Xandros (32-bit)
Xandros_64		Xandros (64-bit)
Linux		Arch Linux (32-bit)
Linux_64		Arch Linux (64-bit)
Solaris		Oracle Solaris 10 5/09 and earlier (32-bit)
Solaris_64		Oracle Solaris 10 5/09 and earlier (64-bit)
OpenSolaris		Oracle Solaris 10 10/09 and later (32-bit)
OpenSolaris_64		Oracle Solaris 10 10/09 and later (64-bit)
Solaris11_64		Oracle Solaris 11 (64-bit)
FreeBSD		FreeBSD (32-bit)
FreeBSD_64		FreeBSD (64-bit)
OpenBSD		OpenBSD (32-bit)
OpenBSD_64		OpenBSD (64-bit)
NetBSD		NetBSD (32-bit)
NetBSD_64		NetBSD (64-bit)
OS2Warp3		OS/2 Warp 3
OS2Warp4		OS/2 Warp 4
OS2Warp45		OS/2 Warp 4.5
OS2eCS		eComStation
OS21x		OS/2 1.x
OS2		Other OS/2
MacOS		Mac OS X (32-bit)
MacOS_64		Mac OS X (64-bit)
MacOS106		Mac OS X 10.6 Snow Leopard (32-bit)
MacOS106_64		Mac OS X 10.6 Snow Leopard (64-bit)
MacOS107_64		Mac OS X 10.7 Lion (64-bit)
MacOS108_64		Mac OS X 10.8 Mountain Lion (64-bit)
MacOS109_64		Mac OS X 10.9 Mavericks (64-bit)
MacOS1010_64		Mac OS X 10.10 Yosemite (64-bit)
MacOS1011_64		Mac OS X 10.11 El Capitan (64-bit)
MacOS1012_64		macOS 10.12 Sierra (64-bit)
MacOS1013_64		macOS 10.13 High Sierra (64-bit)
DOS		DOS
Netware		Netware
L4		L4
QNX		QNX
JRockitVE		JRockitVE
VBoxBS_64		VirtualBox Bootsector Test (64-bit)
```
