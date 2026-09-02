<?php
class SqlCommand{
    // ---------- <Constructor> ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    function __Construct(){}

    // ---------- <SQL Scripts> ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    public function select_termelesFolyamat1()	        {return "SELECT * FROM [dbo].[Termeles_folyamat1] ()";}
    public function select_termelesFolyamat2()	        {return "SELECT * FROM [dbo].[Termeles_folyamat2] ()";}
    public function select_termelesKosar()	            {return "SELECT b FROM [dbo].[Termeles_kosar] ()";}
    public function exec_termelesFolyamat1Felvitele()   {return "EXEC [dbo].[Termeles_folyamat1_felvitele] :parameter, :output";}
    public function exec_termelesKosarZaras()           {return "EXEC [dbo].[Termeles_kosar_zaras] :id, :user_id, :output";}
}