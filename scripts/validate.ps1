$ErrorActionPreference = 'Stop'

Write-Host '== P0 Mobile Lab validation =='
flutter --version
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test

Write-Host 'Validation complete.'
