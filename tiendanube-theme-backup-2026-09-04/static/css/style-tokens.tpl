{# /* Style tokens */ #}

:root {

  {#/*============================================================================
    #Colors
  ==============================================================================*/#}
  
  {#### Colors settings #}

  {# Main colors #}

  {% set main_background = settings.background_color %}
  {% set main_foreground = settings.text_color %}

  {% set accent_color = settings.accent_color %}

  {% set button_background = settings.button_background_color %}
  {% set button_foreground = settings.button_foreground_color %}
  
  {% set label_background = settings.label_background_color %}
  {% set label_foreground = settings.label_foreground_color %}

  {# Optional colors #}

  {% set adbar_background = settings.adbar_colors ? settings.adbar_background_color : main_background %}
  {% set adbar_foreground = settings.adbar_colors ? settings.adbar_foreground_color : main_foreground %}

  {% set header_background = settings.header_colors ? settings.header_background_color : main_background %}
  {% set header_foreground = settings.header_colors ? settings.header_foreground_color : main_foreground %}

  {% set header_transparent_foreground = settings.head_transparent_contrast_options ? settings.header_transparent_foreground_color : '' %}

  {% set footer_background = settings.footer_colors ? settings.footer_background_color : main_background %}
  {% set footer_foreground = settings.footer_colors ? settings.footer_foreground_color : main_foreground %}

  {% set newsletter_background = settings.home_news_background_color %}
  {% set newsletter_foreground = settings.home_news_foreground_color %}

  {% set banner_services_background = settings.banner_services_colors ? settings.banner_services_background_color : '' %}
  {% set banner_services_foreground = settings.banner_services_colors ? settings.banner_services_foreground_color : '' %}

  {#### CSS Colors #}

  {# Main colors #}

  --main-foreground: {{ main_foreground }};
  --main-background: {{ main_background }};

  --accent-color: {{ accent_color }};

  --button-background: {{ button_background }};
  --button-foreground: {{ button_foreground }};

  --label-background: {{ label_background }};
  --label-foreground: {{ label_foreground }};

  {# Optional colors #}

  --adbar-background: {{ adbar_background }};
  --adbar-foreground: {{ adbar_foreground }};

  --header-background: {{ header_background }};
  --header-foreground: {{ header_foreground }};
  --header-transparent-foreground: {{ header_transparent_foreground }};

  --footer-background: {{ footer_background }};
  --footer-foreground: {{ footer_foreground }};

  --newsletter-background: {{ newsletter_background }};
  --newsletter-foreground: {{ newsletter_foreground }};

  --services-background: {{ banner_services_background }};
  --services-foreground: {{ banner_services_foreground }};

  {# Color shades #}

  {# Opacity hex levels #}

  {% set opacity_03 = '08' %}
  {% set opacity_05 = '0D' %}
  {% set opacity_07 = '12' %}
  {% set opacity_10 = '1A' %}
  {% set opacity_20 = '33' %}
  {% set opacity_30 = '4D' %}
  {% set opacity_40 = '66' %}
  {% set opacity_50 = '80' %}
  {% set opacity_60 = '99' %}
  {% set opacity_70 = 'B3' %}
  {% set opacity_80 = 'CC' %}
  {% set opacity_90 = 'E6' %}
  {% set opacity_95 = 'F2' %}

  --main-foreground-opacity-03: {{ main_foreground }}{{ opacity_03 }};
  --main-foreground-opacity-05: {{ main_foreground }}{{ opacity_05 }};
  --main-foreground-opacity-07: {{ main_foreground }}{{ opacity_07 }};
  --main-foreground-opacity-10: {{ main_foreground }}{{ opacity_10 }};
  --main-foreground-opacity-20: {{ main_foreground }}{{ opacity_20 }};
  --main-foreground-opacity-30: {{ main_foreground }}{{ opacity_30 }};
  --main-foreground-opacity-40: {{ main_foreground }}{{ opacity_40 }};
  --main-foreground-opacity-50: {{ main_foreground }}{{ opacity_50 }};
  --main-foreground-opacity-80: {{ main_foreground }}{{ opacity_80 }};

  --main-background-opacity-20: {{ main_background }}{{ opacity_20 }};
  --main-background-opacity-30: {{ main_background }}{{ opacity_30 }};
  --main-background-opacity-50: {{ main_background }}{{ opacity_50 }};
  --main-background-opacity-80: {{ main_background }}{{ opacity_80 }};
  --main-background-opacity-90: {{ main_background }}{{ opacity_90 }};
  --main-background-opacity-95: {{ main_background }}{{ opacity_95 }};

  --header-foreground-opacity-20: {{ header_foreground }}{{ opacity_20 }};
  --header-foreground-opacity-30: {{ header_foreground }}{{ opacity_30 }};

  --news-foreground-opacity-30: {{ newsletter_foreground }}{{ opacity_30 }};
  --news-foreground-opacity-50: {{ newsletter_foreground }}{{ opacity_50 }};

  --footer-foreground-opacity-10: {{ footer_foreground }}{{ opacity_10 }};
  --footer-foreground-opacity-20: {{ footer_foreground }}{{ opacity_20 }};
  --footer-foreground-opacity-30: {{ footer_foreground }}{{ opacity_30 }};
  --footer-foreground-opacity-60: {{ footer_foreground }}{{ opacity_60 }};
  --footer-foreground-opacity-80: {{ footer_foreground }}{{ opacity_80 }};

  {# Alert colors CSS #}

  --success: #4bb98c;
  --danger: #dd7774;
  --warning: #dc8f38;
  --info: #71b5dc;

  {#/*============================================================================
    #Fonts
  ==============================================================================*/#}

  {# Font families #}

  --heading-font: {{ settings.font_headings | raw }};
  --body-font: {{ settings.font_rest | raw }};

  {# Font sizes #}

  {% set heading_size = settings.headings_size %}

  --h1: {{ heading_size }}px;
  --h1-huge: {{ heading_size + 2 }}px;
  --h1-huge-md: {{ heading_size + 16 }}px;
  --h2: {{ heading_size - 4 }}px;
  --h3: {{ heading_size - 8 }}px;
  --h4: {{ heading_size - 10 }}px;
  --h5: {{ heading_size - 12 }}px;
  --h6: {{ heading_size - 14 }}px;
  --h6-small: {{ heading_size - 16 }}px;
 
  {% set font_rest_size = settings.font_rest_size %}

  --font-huge: {{ font_rest_size + 10 }}px;
  --font-large: {{ font_rest_size + 4 }}px;
  --font-big: {{ font_rest_size + 2 }}px;
  --font-base: {{ font_rest_size }}px;
  --font-small: {{ font_rest_size - 2 }}px;
  --font-smallest: {{ font_rest_size - 4 }}px;

  {# Titles weight #}

  {% set title_weight = settings.headings_bold ? '700' : '400' %}

  --title-font-weight: {{ title_weight }};

  {#/*============================================================================
    #Width
  ==============================================================================*/#}

  {# Container #}

  {% set container_width = settings.container_width %}

  --container-width: {{ container_width + 60 }}px;
  --container-width-large: {{ container_width }}px;
  --container-width-medium: {{ container_width - 240 }}px;

  {#/*============================================================================
    #Spacing
  ==============================================================================*/#}

  {# Gutters #}

  --gutter: 15px;
  --guter-container: 30px;
  --guter-container-md: 40px;
  --gutter-negative: calc(var(--gutter) * -1);
  --gutter-half: calc(var(--gutter) / 2);
  --gutter-half-negative: calc(var(--gutter) * -1 / 2);
  --gutter-double: calc(var(--gutter) * 2);

  {#/*============================================================================
    #Misc
  ==============================================================================*/#}

  {# Borders #}

  --border-radius: 4px;
  --border-radius-half: calc(var(--border-radius) / 2);
  --border-radius-quarter: calc(var(--border-radius) / 4);
  --border-radius-circle: 100%;
  --border-solid: 1px solid;
  --border-dashed: 1px dashed;

  {# Shadows #}

  --shadow-distance: 0 0 5px;

}