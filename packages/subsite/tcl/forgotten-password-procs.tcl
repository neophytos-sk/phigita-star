ad_proc xo__auth_secret_tokens__sweep {} {
    set conn [DB_Connection new -volatile]
    $conn do "delete from xo__auth_secret_tokens where creation_date < CURRENT_TIMESTAMP - '24 hours'::interval"
}
