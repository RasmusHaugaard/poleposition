# avr
Kildekoden er i mappen "src" (source code).
Filerne "makefile" og "package.json" samt mappen "scripts" beskriver vores build-setup.

## guide
Installer avra og avrdude.  
Installer node.js (indeholder npm).  
Åben en terminal ved denne mappe.  
Installer watch-cli globalt:  
```
sudo npm i -g watch-cli
```  
Nu kan man assemble og flashe med usb:  
```
make
```  
kun assemble:  
```
make assemble
```  
assemble og flashe med usb, når der er filændringer:  
```
make watch
```  
kun assemble, når der er filændringer:  
```
make watchassemble
```  

## build setup
Kildekoden, "src", gives til preprocessoren.
Preprocessorens output lægges i en ny mappe "temp" (temporary).
Assembleren køres så fra mappen "temp".
Assemblerens output flyttes fra mappen "temp" over i en ny mappe "build".

Da mapperne "temp" og "build" altid kan genereres udfra kildekoden, ønsker vi ikke at versionsstyre disse mapper, og de er derfor tilføjet til filen ".gitignore", der fortæller git, vi ikke ønsker, git skal styre indholdet af mapperne.

## preprocessor
### why
Når man opbygger kode i moduler, er det ønskværdigt, koden udenfor et givet modul skal vide så lidt som muligt om koden inde i modulet og omvendt.
Det betyder blandt andet i dette projekt, at man, når man inkludere et modul i et program, at man helst ikke skal tage hensyn til, hvilke registre, modulet bruger.
Assembleren læser og assembler linje for linje. Den starter med entry-filen. Når ".include" direktivet mødes, læses den inkluderede fil linje for linje, før resten af entry-filen læses.
Vi vil gerne kunne definere (navngive) registre inde i et modul, uden de "leaker" og påvirker definitioner, der bruges i resten af koden.
I atmels assembler, tilgodeser direktivet ".undef" tildels dette. Assembleren, avra, understøtter pt ikke dette direktiv.
Kombinationen af ".def" og ".undef" tilbyder dog ikke nogen nem måde at gå ned i scope. Hvis et register, som allerede er defineret, skal omdefineres i stykke kode, skal man skrive koden, der gemmer den gamle definition før kodestykket og genindsætter den efter kodestykket.

### what
Det bedste ville være at løse problemerne med avras assembler eller benytte atmels assembler. Vi har desværre ikke erfaring eller til til at rode i kildekoden til avras assembler, og der er ikke distributioner af atmels assembler til linux og osx.
Man kunne implementere ".def" og ".undef" i en preprocessor, så det virkede på samme måde som, og var kompatibelt med atmels assembler. Det er muligvis det næstbedste, men på grund af begrænset tid, vælges en simplere løsning:

Der indføres et nyt direktiv, der fungerer på samme måde som direktivet, ".def", men er begrænset af file scope.

### how
Preprocessoren er skrevet i node.js, en javascript runtime med adgang til filsystemet.
Overvejelser ved valg af programmeringssprog:  
- Erfaring med javascript.  
- Node Package Manager, det største open source netværk af værktøjer.
- Distributioner til både linux, osx og windows.
- Intet build-setup. Kode kompileres ved runtime.

Preprocessoren læser alle ".inc" og ".asm" filer i mappen "src".
For hver fil:
- Gennemsøges filen for tekststrengen ".filedef" og gemmer de definitioner, der måtte være. Hvis et navn eller et register er defineret flere gange i samme fil, afbrydes programmet med en fejlmeddelelse.
- Filen gennemsøges nu for navnene, der måtte være defineret, og erstatter dem med registrene.
- Den nye fil gemmes i en ny mappe.

Der bruges regular expressions til at lede efter både direktiv og navne.
Alle filerne bearbejdes synkront, dvs. én ad gangen, for at gøre koden nemmere at læse. Der ville sandsynligvis være et stor performance boost ved at omskrive koden til at bruge asynkrone metoder. Vores kildekode bliver preprocessed på ca. 50 ms, så vi har ikke fokuseret på at optimere.
