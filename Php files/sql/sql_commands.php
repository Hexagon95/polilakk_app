<?php
class SqlCommand{
    // ---------- <Constructor> ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    function __Construct(){}

    // ---------- <SQL Scripts> ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    public function select_termelesFolyamat1()	        {return "SELECT * FROM [dbo].[Termeles_folyamat1] ()";}
    public function exec_termelesFolyamat1Felvitele()   {return "EXEC [dbo].[Termeles_folyamat1_felvitele] :parameter, :output";}
}