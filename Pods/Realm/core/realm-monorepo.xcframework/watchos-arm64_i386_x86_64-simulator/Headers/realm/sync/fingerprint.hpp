#ifndef REALM_ENCRYPT_FINGERPRINT_HPP
#define REALM_ENCRYPT_FINGERPRINT_HPP

#include <string>
#include <array>

#include <realm/util/optional.hpp>

namespace realm {
namespace encrypt {

// calculate_fingerprint() calculates, and returns, a fingerprint of an
// encryption key. The input key can be util::none in order to calculate a
// fingerprint even in the case of unencrypted Realms.
//
// An intruder cannot recover an unknown encryption_key from the fingerprint,
// and it is safe to save the fingerprint in a file together with the encrypted
// Realms.
//
// calculate_fingerprint() can be considered opaque, but currently the
// fingerprint is a colon separated hex representation of the SHA-256 hash of
// the encryption key.
std::string calculate_fingerprint(const util::Optional<std::array<char, 64>> encryption_key);

// verify_fingerprint() returns true if `fingerprint` was obtained previously
// from calculate_fingerprint() with `encryption_key` as argument.  Otherwise,
// verify_fingerprint() returns false with extremely high probability.
bool verify_fingerprint(const std::string& fingerprint, const util::Optional<std::array<char, 64>> encryption_key);

} // namespace encrypt
} // namespace realm

#endif // REALM_ENCRYPT_FINGERPRINT_HPP
