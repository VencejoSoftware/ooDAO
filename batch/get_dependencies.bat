@echo off

if not exist %delphiooLib%\ooBatch\ (
  @echo "Clonning ooBatch..."
  git clone https://github.com/VencejoSoftware/ooBatch.git %delphiooLib%\ooBatch\
  call %delphiooLib%\ooBatch\code\get_dependencies.bat
)

if not exist %delphi3rdParty%\generics.collections\ (
  @echo "Clonning generics.collections..."
  git clone https://github.com/VencejoSoftware/generics.collections.git %delphi3rdParty%\generics.collections\
)

if not exist %delphi3rdParty%\zeosdbo\ (
  @echo "Clonning zeosdbo..."
  git clone https://github.com/VencejoSoftware/zeosdbo.git %delphi3rdParty%\zeosdbo\
)

if not exist %delphiooLib%\ooEntity\ (
  @echo "Clonning ooEntity..."
  git clone https://github.com/VencejoSoftware/ooEntity.git %delphiooLib%\ooEntity\
  call %delphiooLib%\ooEntity\batch\get_dependencies.bat
)

if not exist %delphiooLib%\ooSQL\ (
  @echo "Clonning ooSQL..."
  git clone https://github.com/VencejoSoftware/ooSQL.git %delphiooLib%\ooSQL\
  call %delphiooLib%\ooSQL\batch\get_dependencies.bat
)

if not exist %delphiooLib%\ooLog\ (
  @echo "Clonning ooLog..."
  git clone https://github.com/VencejoSoftware/ooLog.git %delphiooLib%\ooLog\
  call %delphiooLib%\ooLog\batch\get_dependencies.bat
)