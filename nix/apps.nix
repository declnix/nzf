{ outputs, pkgs, writeShellScript, ... }: {
  vm = writeShellScript "vm" ''
    set -e
    VM_PATH="${outputs.nixosConfigurations.testvm.config.system.build.vm}/bin/run-vm-vm"

    # Domyślne opcje
    DISPLAY_OPTS="-display none"
    SERIAL_OPTS="-serial mon:stdio"

    # Możliwość przekazania własnych argumentów
    if [ $# -gt 0 ]; then
      exec "$VM_PATH" "$@"
    else
      exec "$VM_PATH" $DISPLAY_OPTS $SERIAL_OPTS
    fi
  '';
}
