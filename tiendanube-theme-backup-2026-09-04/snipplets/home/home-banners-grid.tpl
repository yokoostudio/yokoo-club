{% set banner = banner | default(false) %}
{% set banner_promotional = banner_promotional | default(false) %}
{% set banner_news = banner_news | default(false) %}
{% set module = module | default(false) %}

{% set theme_editor = params.preview %}

{% if banner %}
    {% set has_banners = settings.banner and settings.banner is not empty %}
    {% set has_mobile_banners = settings.toggle_banner_mobile and settings.banner_mobile and settings.banner_mobile is not empty %}
    {% set section_banner = mobile ? settings.banner_mobile : settings.banner %}
    {% set section_title = settings.banner_title %}
    {% set section_slider = settings.banner_slider %}
    {% set section_id = mobile ? 'banners-mobile' : 'banners' %}
    {% set section_columns_desktop_4 = settings.banner_columns_desktop == 4 %}
    {% set section_columns_desktop_3 = settings.banner_columns_desktop == 3 %}
    {% set section_columns_desktop_2 = settings.banner_columns_desktop == 2 %}
    {% set section_columns_desktop_1 = settings.banner_columns_desktop == 1 %}
    {% set section_align_text = settings.banner_align == 'center' ? 'text-center' : 'textbanner-text-left' %}
    {% set section_same_size = settings.banner_same_size %}
    {% set section_without_margins = settings.banner_without_margins %}
    {% set section_text_outside = settings.banner_text_outside %}
    {% set section_first = settings.home_order_position_1 == 'categories' %}
{% endif %}
{% if banner_promotional %}
    {% set has_banners = settings.banner_promotional and settings.banner_promotional is not empty %}
    {% set has_mobile_banners = settings.toggle_banner_promotional_mobile and settings.banner_promotional_mobile and settings.banner_promotional_mobile is not empty %}
    {% set section_banner = mobile ? settings.banner_promotional_mobile : settings.banner_promotional %}
    {% set section_title = settings.banner_promotional_title %}
    {% set section_slider = settings.banner_promotional_slider %}
    {% set section_id = mobile ? 'banners-promotional-mobile' : 'banners-promotional' %}
    {% set section_columns_desktop_4 = settings.banner_promotional_columns_desktop == 4 %}
    {% set section_columns_desktop_3 = settings.banner_promotional_columns_desktop == 3 %}
    {% set section_columns_desktop_2 = settings.banner_promotional_columns_desktop == 2 %}
    {% set section_columns_desktop_1 = settings.banner_promotional_columns_desktop == 1 %}
    {% set section_align_text = settings.banner_promotional_align == 'center' ? 'text-center' : 'textbanner-text-left' %}
    {% set section_same_size = settings.banner_promotional_same_size %}
    {% set section_without_margins = settings.banner_promotional_without_margins %}
    {% set section_text_outside = settings.banner_promotional_text_outside %}
    {% set section_first = settings.home_order_position_1 == 'promotional' %}
{% endif %}
{% if banner_news %}
    {% set has_banners = settings.banner_news and settings.banner_news is not empty %}
    {% set has_mobile_banners = settings.toggle_banner_news_mobile and settings.banner_news_mobile and settings.banner_news_mobile is not empty %}
    {% set section_banner = mobile ? settings.banner_news_mobile : settings.banner_news %}
    {% set section_title = settings.banner_news_title %}
    {% set section_slider = settings.banner_news_slider %}
    {% set section_id = mobile ? 'banners-news-mobile' : 'banners-news' %}
    {% set section_columns_desktop_4 = settings.banner_news_columns_desktop == 4 %}
    {% set section_columns_desktop_3 = settings.banner_news_columns_desktop == 3 %}
    {% set section_columns_desktop_2 = settings.banner_news_columns_desktop == 2 %}
    {% set section_columns_desktop_1 = settings.banner_news_columns_desktop == 1 %}
    {% set section_align_text = settings.banner_news_align == 'center' ? 'text-center' : 'textbanner-text-left' %}
    {% set section_same_size = settings.banner_news_same_size %}
    {% set section_without_margins = settings.banner_news_without_margins %}
    {% set section_text_outside = settings.banner_news_text_outside %}
    {% set section_first = settings.home_order_position_1 == 'news_banners' %}
{% endif %}
{% if module %}
    {% set section_banner = settings.module %}
    {% set section_slider = settings.module_slider %}
    {% set section_id = 'modules' %}
    {% set section_same_size = settings.module_same_size %}
    {% set section_without_margins = settings.module_without_margins %}
    {% set section_text_outside = true %}
    {% set section_first = settings.home_order_position_1 == 'modules' %}
    {% set section_align_text = 'text-center' %}
{% endif %}

{% set visibility_classes = 
    has_banners and has_mobile_banners ? (mobile ? 'd-md-none' : 'd-none d-md-block') 
    : not has_banners and has_mobile_banners and not mobile ? 'd-none' 
%}

<div class="js-{{ section_id }} {% if not module %}{{ visibility_classes }}{% endif %}">
    <div class="js-banner-container container">
        {% if not module %}
            <h2 class="js-banners-section-title js-{{ section_id }}-title section-title h3 mt-3 mb-4 pb-2 text-center"{% if not section_title %} style="display:none;"{% endif %}>{{ section_title }}</h2>
        {% endif %}
    {% if section_without_margins %}
    </div>
    <div class="js-banner-container container-fluid p-0 overflow-none">
    {% endif %}
        {% if section_slider %}
            <div class="js-swiper-{{ section_id }} swiper-container">
                <div class="js-banner-row swiper-wrapper">
        {% elseif not module or (module and theme_editor) %}
            <div class="js-banner-row row justify-content-center {% if section_without_margins %}no-gutters{% endif %}">
        {% endif %}

        {% for slide in section_banner %}

            {% set has_banner_text = slide.title or slide.description or slide.button %}

            {% set apply_lazy_load = not (section_first and loop.first) %}

            {% if apply_lazy_load %}
                {% set slide_src = 'images/empty-placeholder.png' | static_url %}
            {% else %}
                {% set slide_src = slide.image | static_url | settings_image_url('large') %}
            {% endif %}

            {% if not module or (module and (section_slider or theme_editor)) %}
                <div class="js-banner {% if section_slider %}swiper-slide {% else %}col-grid {% if section_columns_desktop_4 %}col-md-3{% elseif section_columns_desktop_3 %}col-md-4{% elseif section_columns_desktop_2 %}col-md-6{% elseif section_columns_desktop_1 %}col-md-12{% endif %}{% endif %}">
            {% endif %}
                    <div class="js-textbanner textbanner {{ section_align_text }} {% if section_without_margins %} m-0{% endif %}{% if module and not (section_without_margins or section_slider) %} mb-md-5 pb-md-5{% endif %}">
                        {% if slide.link %}
                            <a href="{{ slide.link | setting_url }}" class="textbanner-link" aria-label="{{ 'Carrusel' | translate }} {{ loop.index }}">
                        {% endif %}
                        {% if module %}
                            <div class="row no-gutters align-items-center">
                        {% endif %}
                        <div class="js-textbanner-image-container {% if module %}col-md-6 {% if section_same_size %}textbanner-image-md {% endif %}{% endif %}textbanner-image{% if not section_same_size %} p-0{% endif %}{% if has_banner_text and not section_text_outside %} overlay{% endif %} overflow-none">
                            
                            {% set apply_lazy_load = 
                                not section_first 
                                or not (
                                    loop.first and (
                                        (has_banners and not has_mobile_banners) or 
                                        (has_mobile_banners and mobile) or module
                                    )
                                ) 
                            %}

                            {% if apply_lazy_load %}
                                {% set slide_src = 'data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==' %}
                            {% else %}
                                {% set slide_src = slide.image | static_url | settings_image_url('large') %}
                            {% endif %}
                            
                            <img 
                                {% if not apply_lazy_load %}fetchpriority="high"{% endif %}
                                {% if slide.width and slide.height %} width="{{ slide.width }}" height="{{ slide.height }}" {% endif %} 
                                {% if apply_lazy_load %}data-{% endif %}src="{{ slide_src }}"
                                {% if apply_lazy_load %}
                                data-sizes="auto" 
                                data-expand="-10"
                                {% endif %}
                                {% if apply_lazy_load %}data-{% endif %}srcset="{{ slide.image | static_url | settings_image_url('large') }} 480w, {{ slide.image | static_url | settings_image_url('huge') }} 640w, {{ slide.image | static_url | settings_image_url('original') }} 1024w, {{ slide.image | static_url | settings_image_url('1080p') }} 1920w" 
                                class="js-textbanner-image textbanner-image-effect {% if section_same_size %}textbanner-image-background{% else %}img-fluid d-block w-100{% endif %} {% if apply_lazy_load %}lazyautosizes lazyload fade-in{% endif %}" 
                                {% if slide.title %}alt="{{ banner_title }}"{% else %}alt="{{ 'Banner de' | translate }} {{ store.name }}"{% endif %} 
                            />
                            {% if apply_lazy_load %}
                                <div class="placeholder-fade placeholder-banner"></div>
                            {% endif %}
                        {% if section_text_outside %}
                            </div>
                        {% endif %}
                        {% if has_banner_text %}
                            <div class="js-textbanner-text {% if module %}col-md-6 px-3 px-md-4 {% if loop.index is even %}order-md-first {% endif %}{% endif %}textbanner-text {% if not section_text_outside %} over-image{% if section_columns_desktop_1 %} w-md-50{% endif %}{% endif %} {% if not section_text_outside and slide.color == 'light' %}over-image-invert{% endif %}{% if section_text_outside and section_without_margins %} pb-4{% endif %}">
                                {% if slide.title %}
                                    <h3 class="js-banner-title {% if module %}h3{% else %}h1-huge{% endif %} {% if slide.description or (slide.button and slide.link) %}mb-3{% else %}mb-0{% endif %}{% if not module and section_columns_desktop_4 %} h3-md{% endif %}">{{ slide.title }}</h3>
                                {% endif %}
                                {% if slide.description %}
                                    <div class="textbanner-paragraph{% if slide.button and slide.link %} mb-3{% endif %}">{{ slide.description }}</div>
                                {% endif %}
                                {% if slide.button and slide.link %}
                                    <div class="btn-link">{{ slide.button }}</div>
                                {% endif %}
                            </div>
                        {% endif %}
                        {% if not section_text_outside or module %}
                            </div>
                        {% endif %}
                        {% if slide.link %}
                            </a>
                        {% endif %}
                    </div>
            {% if not module or (module and (section_slider or theme_editor)) %}
                </div>
            {% endif %}
        {% endfor %}
        {% if section_slider %}
                </div>
            </div>
            {% if section_banner and section_banner is not empty or theme_editor %}
                <div class="js-swiper-{{ section_id }}-controls text-center{% if section_without_margins %} mt-2{% endif %}{% if module %} w-100{% endif %}">
                    <div class="js-swiper-{{ section_id }}-prev swiper-button-prev svg-icon-text">
                        <svg class="icon-inline icon-lg icon-flip-horizontal"><use xlink:href="#arrow-long"/></svg>
                    </div>
                    <div class="js-swiper-{{ section_id }}-pagination swiper-pagination-fraction"></div>
                    <div class="js-swiper-{{ section_id }}-next swiper-button-next svg-icon-text">
                        <svg class="icon-inline icon-lg"><use xlink:href="#arrow-long"/></svg>
                    </div>
                </div>
            {% endif %}
        {% elseif not module or (module and theme_editor) %}
            </div>
        {% endif %}
    </div>
</div>
