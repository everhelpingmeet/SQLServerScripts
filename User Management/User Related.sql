
--You will have to be cautious, any account changes will lead to application failure.
--Make all necessary changes in the application

--Rename a user
ALTER LOGIN [<accountotberenamed>] WITH NAME = [<newnameoftheaccount>]

--Enabling a disabled login
ALTER LOGIN [<accounttobeenabled>] ENABLE;

--Changing the password of a login
ALTER LOGIN [<accountforpasswordchange>] WITH PASSWORD = '<enterpassword>';


--Changing the password when you are logged in
ALTER LOGIN [<accountforpasswordchange>] WITH PASSWORD = '<enternewpassword>' OLD_PASSWORD = '<enteroldpassword>';


--Unlocking a login
ALTER LOGIN [<accountotbeunlocked>] WITH PASSWORD = '****' UNLOCK ;

--To unlock a login without changing the password
ALTER LOGIN [<accountotbeunlocked>] WITH CHECK_POLICY = OFF;
ALTER LOGIN [<accountotbeunlocked>] WITH CHECK_POLICY = ON;
