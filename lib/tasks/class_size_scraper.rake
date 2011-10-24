require 'mechanize'
require 'logger'
require 'uri'

def class_size_scrape
	start_url = "https://apps.uillinois.edu/selfservice/"
	login_url = "https://webprod.admin.uillinois.edu/ssa/servlet/SelfServiceLogin?appName=edu.uillinois.aits.SelfServiceLogin&dad=BANPROD1"
	host = "eas.admin.uillinois.edu"
	uri = URI.parse(host)
	home_url = "https://ui2web1.apps.uillinois.edu/BANPROD1/twbkwbis.P_GenMenu?name=bmenu.P_MainMnu"

	a = Mechanize.new
	a.user_agent = Mechanize::AGENT_ALIASES["Windows Mozilla"]

	a.log = Logger.new(STDOUT)

		Mechanize::Cookie.parse(uri, "RedirectString=" + login_url) do |cookie|
			cookie.domain = "eas.admin.uillinois.edu"
			cookie.path = "/"
			uri.host = cookie.domain
			a.cookie_jar.add(uri, cookie)
		end

	a.get(start_url) do |page|

		login_page = a.click(page.link_with(:text => "University of Illinois at Urbana-Champaign (URBANA)"))

		f = login_page.form('easForm')
		f.inputEnterpriseId  = ARGV[0]
		f.password			 = ARGV[1]
		logged_in =  f.click_button
		#reg_menu = a.get("https://ui2web1.apps.uillinois.edu/BANPROD1/twbkwbis.P_GenMenu?name=bmenu.P_RegMnu")
	end
end

namespace :scrape do 

  task :setup do
	class_size_scrape
  end
  
end
