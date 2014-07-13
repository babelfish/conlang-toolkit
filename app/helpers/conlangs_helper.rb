module ConlangsHelper
  def value_or_nbsp input, additional
    if input.blank?
      return "&nbsp;".html_safe
    else
      return input + (additional or "")
    end
  end
end
