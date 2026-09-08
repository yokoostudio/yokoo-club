{% if settings.main_categories and settings.slider_categories and settings.slider_categories is not empty %}
    <section class="section-categories-home position-relative" data-store="home-categories-featured">
        <div class="container">
            {% if settings.main_categories_title %}
                <h2 class="h3 mt-3 mb-4 text-center">{{ settings.main_categories_title }}</h2>
            {% endif %}
            <div class="js-swiper-categories swiper-container">
                <div class="swiper-wrapper">
                    {% for slide in settings.slider_categories %}
                        <div class="swiper-slide w-md-auto">
                            {% if slide.link %}
                                <a href="{{ slide.link | setting_url }}" class="js-home-category" aria-label="{{ 'Categoría' | translate }} {{ loop.index }}">
                            {% endif %}
                                <div class="home-category text-center">
                                    <div class="home-category-image home-category-image-md">
                                        <img src="{{ 'images/empty-placeholder.png' | static_url }}" data-src="{{ slide.image | static_url | settings_image_url('small') }}" class="swiper-lazy fade-in" alt="{{ 'Categoría' | translate }} {{ loop.index }}">
                                        <div class="placeholder-fade"></div>
                                        {% if slide.link %}
                                            {% set category_handle = slide.link | trim('/') | split('/') | last %}
                                            {% include 'snipplets/home/home-categories-name.tpl' %}
                                        {% endif %}
                                    </div>
                                </div>
                            {% if slide.link %}
                                </a>
                            {% endif %}
                        </div>
                    {% endfor %}
                </div>
            </div>
            <div class="text-center mt-4">
                <div class="js-swiper-categories-prev swiper-button-prev svg-icon-text">
                    <svg class="icon-inline icon-lg icon-flip-horizontal"><use xlink:href="#arrow-long"/></svg>
                </div>
                <div class="js-swiper-categories-next swiper-button-next svg-icon-text">
                    <svg class="icon-inline icon-lg"><use xlink:href="#arrow-long"/></svg>
                </div>
            </div>
        </div>
    </section>
{% endif %}
