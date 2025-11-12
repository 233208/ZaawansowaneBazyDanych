CREATE ROLE [dbmanager]
    AUTHORIZATION [dbo];


GO
GRANT ALTER
    ON ROLE::[dbmanager] TO [CloudSA91dbf975]
    WITH GRANT OPTION;


GO
GRANT ALTER
    ON ROLE::[dbmanager] TO [233208@student.uek.krakow.pl]
    WITH GRANT OPTION;

