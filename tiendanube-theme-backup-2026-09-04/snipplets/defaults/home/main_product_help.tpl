{% set product_view_box = '0 0 1000 1000' %}

<div id="single-product" class="js-product-container section-main-product-home" data-store="home-product-main">
    <div class="container">
        <div class="row">
            <div class="col-md-7 pb-3 pr-md-2">
                <div class="row">
                    <div class="col-md-auto d-none d-md-block pr-0">
                        <div class="product-thumbs-container position-relative">
                            <div class="js-swiper-product-thumbs-demo swiper-product-thumb"> 
                                <div class="swiper-wrapper">
                                    <div class="swper-slide h-auto w-auto">
                                        <div class="js-product-thumb-demo product-thumb d-block position-relative mb-3 selected">
                                            <svg viewBox='{{ product_view_box }}'><use xlink:href="#item-product-placeholder-3"/></svg>
                                        </div>
                                    </div>
                                    <div class="swper-slide h-auto w-auto">
                                        <div class="js-product-thumb-demo product-thumb d-block position-relative mb-3">
                                            <svg viewBox='{{ product_view_box }}'><use xlink:href="#product-image-green-placeholder"/></svg>
                                        </div>
                                    </div>
                                    <div class="swper-slide h-auto w-auto">
                                        <div class="js-product-thumb-demo product-thumb d-block position-relative mb-3">
                                            <svg viewBox='{{ product_view_box }}'><use xlink:href="#product-image-red-placeholder"/></svg>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="mt-2 text-center d-none d-md-block">
                                <div class="js-swiper-product-thumbs-prev-demo swiper-button-small swiper-button-prev swiper-product-thumb-control">
                                    <svg class="icon-inline icon-lg svg-icon-text icon-rotate-90-neg"><use xlink:href="#chevron"/></svg>
                                </div>
                                <div class="js-swiper-product-thumbs-next-demo swiper-button-small swiper-button-next swiper-product-thumb-control">
                                    <svg class="icon-inline icon-lg svg-icon-text icon-rotate-90"><use xlink:href="#chevron"/></svg>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col px-3">
                        <div class="js-swiper-product-demo swiper-container product-detail-slider">
                            <div class="labels">
                                <div class="label label-accent">
                                  -35% OFF
                                </div>
                            </div>
                            <div class="swiper-wrapper">
                                 <div class="js-product-slide-demo w-100 swiper-slide product-slide slider-slide" data-image="0" data-image-position="0">
                                    <div class="d-block p-relative">
                                        <svg viewBox='{{ product_view_box }}'><use xlink:href="#item-product-placeholder-3"/></svg>
                                    </div>
                                 </div>
                                 <div class="js-product-slide-demo w-100 swiper-slide product-slide slider-slide" data-image="1" data-image-position="1">
                                    <div class="d-block p-relative">
                                        <svg viewBox='{{ product_view_box }}'><use xlink:href="#product-image-green-placeholder"/></svg>
                                    </div>
                                 </div>
                                 <div class="js-product-slide-demo w-100 swiper-slide product-slide slider-slide" data-image="2" data-image-position="2">
                                    <div class="d-block p-relative">
                                        <svg viewBox='{{ product_view_box }}'><use xlink:href="#product-image-red-placeholder"/></svg>
                                    </div>
                                 </div>
                            </div>
                        </div>
                        <div class="row no-gutters my-1 text-center align-items-center d-md-none">
                            <div class="js-swiper-product-prev-demo col-auto swiper-button-small swiper-button-prev svg-icon-text mt-0">
                                <svg class="icon-inline icon-lg icon-flip-horizontal"><use xlink:href="#arrow-long"/></svg>
                            </div>
                            <div class="js-swiper-product-pagination-demo col swiper-pagination-fraction font-small"></div>
                            <div class="js-swiper-product-next-demo col-auto swiper-button-small swiper-button-next svg-icon-text mt-0">
                                <svg class="icon-inline icon-lg"><use xlink:href="#arrow-long"/></svg>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col">
                <div class="pt-md-3 mt-2 mt-md-0">
                    <h2 class="h4 h2-md mb-2 text-center text-md-left">{{ "Producto de ejemplo" | translate }}</h2>

                    {# Product price #}

                    {% set price_value = store.country == 'BR' ? '18200' : '182000' %}
                    {% set price_compare_value = store.country == 'BR' ? '28000' : '280000' %}

                    <div class="price-container text-center text-md-left mb-3">
                        <div class="mb-4 mb-md-3">
                            <span class="d-inline-block">
                                {{ price_value | money }}
                            </span>
                            <span class="d-inline-block price-compare">
                                {{ price_value | money }}
                            </span>
                        </div>
                    </div>

                    {# Product installments #}

                    <div class="mb-3 font-small text-center text-md-left">{{ "Hasta 12 cuotas" | translate }}</div>

                    {# Product form, includes: Variants, CTA and Shipping calculator #}

                    <form id="product_form" class="js-product-form mt-4" method="post" action="">
                        <div class="js-product-variants row mb-2">
                            <div class="col-12 text-center text-md-left mb-2">
                                <div class="form-group">
                                    <label class="form-label" for="variation_1">{{ "Color" | translate }}</label>
                                    <select id="variation_1" class="form-select js-variation-option js-refresh-installment-data  " name="variation[0]">
                                        <option value="{{ "Verde" | translate }}">{{ "Verde" | translate }}</option>
                                        <option value="{{ "Rojo" | translate }}">{{ "Rojo" | translate }}</option>
                                    </select>
                                    <div class="form-select-icon">
                                        <svg class="icon-inline icon-w-14 icon-rotate-90"><use xlink:href="#chevron"/></svg>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-4 pr-0 pr-md-3">
                                {% embed "snipplets/forms/form-input.tpl" with{
                                type_number: true, input_value: '1', 
                                input_name: 'quantity' ~ item.id, 
                                input_custom_class: 'js-quantity-input form-control-big form-control-inline', 
                                input_label: false, 
                                input_append_content: true, 
                                input_group_custom_class: 'js-quantity form-quantity', 
                                form_control_container_custom_class: 'col px-0', 
                                form_control_quantity: true,
                                input_min: '1'} %}
                                    {% block input_prepend_content %}
                                    <div class="form-row m-0 align-items-center">
                                        <span class="js-quantity-down form-quantity-icon btn icon-35px font-small">
                                            <svg class="icon-inline"><use xlink:href="#minus"/></svg>
                                        </span>
                                    {% endblock input_prepend_content %}
                                    {% block input_append_content %}
                                        <span class="js-quantity-up form-quantity-icon btn icon-35px font-small">
                                            <svg class="icon-inline"><use xlink:href="#plus"/></svg>
                                        </span>
                                    </div>
                                    {% endblock input_append_content %}
                                {% endembed %}
                            </div>
                            <div class="col-8 pl-md-0 buy-button-container">
                                <input type="submit" class="js-addtocart js-prod-submit-form btn-add-to-cart btn btn-primary btn-big btn-block cart" value="{{ 'Agregar al carrito' | translate }}" />
                            </div>
                        </div>

                    </form>

                    {# Product description #}

                    <div class="mt-2 pb-md-4 text-center mt-md-3 text-md-left">
                        <p>{{ "¡Este es un producto de ejemplo! Para poder probar el proceso de compra, debes" | translate }}
                            <a href="/admin/products" target="_top">{{ "agregar tus propios productos." | translate }}</a>
                        </p>
                    </div>
                </div>                
            </div>
        </div>
    </div>  
</div>