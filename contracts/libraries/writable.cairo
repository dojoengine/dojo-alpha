%lang starknet

from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE

//
// Events
//

@event
func WriterGranted(account: felt) {
}

@event
func WriterRevoked(account: felt) {
}

@event
func AdminChanged(admin: felt) {
}

//
// Storage
//

@storage_var
func Writable_admin() -> (admin: felt) {
}

@storage_var
func Writable_writers(account: felt) -> (is_writer: felt) {
}

namespace Writable {
    //
    // Initialize
    //

    func initialize{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(admin: felt) {
        _set_admin(admin);
        return ();
    }

    //
    // Modifier
    //

    func assert_only_writer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
        alloc_locals;
        let (caller) = get_caller_address();
        let (authorized) = is_writer(caller);
        with_attr error_message("Writable: not writer") {
            assert authorized = TRUE;
        }
        return ();
    }

    func assert_only_admin{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
        alloc_locals;
        let (caller) = get_caller_address();
        let (authorized) = is_admin(caller);
        with_attr error_message("Writable: not admin") {
            assert authorized = TRUE;
        }
        return ();
    }

    //
    // Getters
    //

    func is_writer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        address: felt
    ) -> (authorized: felt) {
        let (authorized) = Writable_writers.read(address);
        return (authorized=authorized);
    }

    func is_admin{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        address: felt
    ) -> (authorized: felt) {
        let (admin_address) = admin();
        if (admin_address == address) {
            return (authorized=TRUE);
        }
        return (authorized=FALSE);
    }

    func admin{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (admin: felt) {
        return Writable_admin.read();
    }

    //
    // Externals
    //

    func grant_writer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        address: felt
    ) {
        assert_only_admin();
        Writable_writers.write(address, TRUE);
        WriterGranted.emit(address);
        return ();
    }

    func revoke_writer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        address: felt
    ) {
        assert_only_admin();
        Writable_writers.write(address, FALSE);
        WriterRevoked.emit(address);
        return ();
    }

    func renounce_writer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        address: felt
    ) {
        let (caller: felt) = get_caller_address();
        with_attr error_message("Writer: can only renounce roles for self") {
            assert address = caller;
        }
        Writable_writers.write(caller, FALSE);
        WriterRevoked.emit(address);
        return ();
    }

    func transfer_admin{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        new_admin: felt
    ) {
        assert_only_admin();
        _set_admin(new_admin);
        return ();
    }

    //
    // Unprotected
    //

    func _set_admin{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        new_admin: felt
    ) {
        Writable_admin.write(new_admin);
        AdminChanged.emit(new_admin);
        return ();
    }
}
