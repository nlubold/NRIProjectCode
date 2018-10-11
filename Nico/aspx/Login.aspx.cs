using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.Security;
using System.IO;
using Nico.csharp.functions;

namespace Nico
{
    public partial class Login : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void ValidateUser(object sender, EventArgs e)
        {
            try
            {

                int loginResult = -1;

                string username = Login1.UserName;
                string password = Login1.Password;
 
                loginResult = SQLLogin.ValidateLogin(username, password);

                switch (loginResult)
                {
                    case 0:
                        Login1.FailureText = "Username and/or password is incorrect. (Error Code: 0)";
                        break;
                    case 1:
                        //FormsAuthentication.RedirectFromLoginPage(Login1.UserName, Login1.RememberMeSet);     
                        FormsAuthentication.SetAuthCookie(Login1.UserName, Login1.RememberMeSet);
                        Response.Redirect("default.aspx", false);
                        break;
                    default:
                        Login1.FailureText = "Username and/or password is incorrect. (Error Code: Unknown)";
                        break;
                }

                
                // Update problem step to first problem and first step but don't reset preset gender/condition info.
                int sessionid = 1;
                int problemid = 1;
                int stepid = 0;
                int stepanswerkey = 1;
                int newanswer = 0;
                int numautoresponses = 0;
                int problemimgkey = 2; // key to the first image in the database
                int numturns = 0;
                string problemSet = "A";
                SQLProblemStepTracker.UpdateProbStep(username, sessionid, problemid, stepid, problemimgkey, stepanswerkey, newanswer, numautoresponses, numturns);
                //SQLConditionGenderInfo.UpdateConditionGender(username, "nonsocial", "female", "192.168.1.208", "none", problemSet,"text");
            }
            catch (Exception eSql)
            {
                SQLLog.InsertLog(DateTime.Now, eSql.Message, eSql.StackTrace, "Login.aspx.c", 1);
            }
        }
        
         
    }
}