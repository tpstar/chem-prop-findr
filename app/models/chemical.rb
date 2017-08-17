class Chemical < ApplicationRecord

  def scrape(q_name)
    chem_search_term = URI.encode(q_name)     # Parsing string to add to URL-encoded URL
    agent = Mechanize.new                     # Use Mechanize to click link and move to product link
    page = agent.get("http://www.sigmaaldrich.com/catalog/search?term=#{chem_search_term}
      &interface=All&N=0&mode=match%20partialmax&lang=en&region=US&focus=product")

    if !page.at("a .name") # if there is no chemical with the searched name
      return               # return back to Chemicals Controller with no name
    end

    # get chemical name
    self.name = page.at("a .name").text

    # get properties from the page (formula, fw)
    properties = []
    page.search(".nonSynonymProperties p").map do |p|
      property = p.text
      properties.push(property)
    end
    # get formula
    formula = properties[0].split(":").last
    formula[0] = "" #this is to remove weird white space left after split
    self.formula = formula
    # get molecular weight (formula weight)
    fw = properties[1].split(":").last
    fw[0] = ""  #this is to remove weird white space left after split
    self.fw = fw

    # some chemical pages have a product link before the actual product link
    # e.g. methylene chloride: in greener alternative ... there is a link to ethyl acetate/ethanol
    # that element has class of resultsTextBanner
    # Let's call that banner
    banner = page.search(".resultsTextBanner").css("a").text

    # if there is no banner click the first product link else click the 4th product link
    (banner == "") ? link_id = 0 : link_id = 3

    # click product link
    product_page = page.links_with(href: %r{^/catalog/product/\w+})[link_id].click
    # some chemical pages have a product link before the actual product link
    # e.g. methylene chloride: in greener alternative ... there is a link to ethyl acetate/ethanol
    # get more properties from product page (generate arrays of strings of keys and values)
    more_properties = []
    product_page.css("#productDetailProperties td").text.split(/\n/).map do |p|
      more_properties.push(p.strip) unless p.strip.empty?
    end

    # get density (get index of "density" first; density value comes after "density" in more_properties array)
    if more_properties.include?("density")
      density_index = more_properties.index("density")
      self.density = more_properties[density_index + 2]
    end
    # get mp (get index of "mp" first; mp value comes after "mp" in more_properties array)
    if more_properties.include?("mp")
      mp_index = more_properties.index("mp")
      self.mp = more_properties[mp_index + 2]
    end
    # get bp (get index of "bp" first; bp value comes after "bp" in more_properties array)
    if more_properties.include?("bp")
      bp_index = more_properties.index("bp")
      self.bp = more_properties[bp_index + 2]
    end
  end
end
