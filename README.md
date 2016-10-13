## Inizializzazione del progetto
Dopo aver scaricato il progetto, eseguire: ./init.sh
Per lavorare sul progetto, usare sempre e solo il workspace, eseguendo: open Softphone.xcworkspace

La prima volta che viene aperto il workspace:
- Selezionare il progetto Pods, poi build Settings. evidenziare Pods nel menù laterale e:
  - Cliccare su Architectures > Other... e aggiungere:
    - x86_64
    - i386
    - armv7s
  - Come base SDK selezionare: Latest iOS
  - Build Active Architectures Only: NO

eseguire il clean and build del progetto:
 - Premere CMD + Shift + K
 Quando termina...
 - Premere CMD + B
 Il build dovrebbe avvenire correttamente

Il clean and build si può anche fare da linea di comando con lo script: ./clean-and-build.sh
