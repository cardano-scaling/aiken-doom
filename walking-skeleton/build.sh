echo "Building..."

aiken build -f all -t verbose
# 1A00DA3360 is 143_000_000 in cbor
aiken blueprint apply -v doom.spend 1A00DA3360  2> /dev/null > tmp
mv tmp plutus.json

echo "New Address:"
aiken address
