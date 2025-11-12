CREATE ROLE [loginmanager]
    AUTHORIZATION [dbo];


GO
GRANT ALTER
    ON ROLE::[loginmanager] TO [CloudSA91dbf975]
    WITH GRANT OPTION;


GO
GRANT ALTER
    ON ROLE::[loginmanager] TO [233208@student.uek.krakow.pl]
    WITH GRANT OPTION;

