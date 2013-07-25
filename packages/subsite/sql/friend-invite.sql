create sequence xo__friend_invite_id__seq;

create table xo__friend_invite_tokens (
	invite_id 	integer not null primary key,

	first_name	varchar(100) not null,
	last_name	varchar(100) not null,
	email		varchar(100) not null,
	token		varchar(50) not null,

	friend_id	integer
			references users(user_id),

	creation_user	integer not null
			references users(user_id),
	creation_ip	varchar(50),
	creation_date	timestamp default CURRENT_TIMESTAMP not null
);
