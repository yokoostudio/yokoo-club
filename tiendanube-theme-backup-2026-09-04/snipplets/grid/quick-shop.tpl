{% if settings.quick_shop %}
    {% embed "snipplets/modal.tpl" with{modal_id: 'quickshop-modal', modal_class: 'quickshop bottom modal-overflow-none', modal_position: 'bottom', modal_transition: 'slide', modal_footer: false, modal_mobile_full_screen: true, modal_width: 'centered-md modal-centered-medium', modal_header_class: 'modal-sticky-close modal-header-no-title d-md-none', modal_title_class: 'd-none d-md-block', modal_body_class: 'modal-scrollable pt-4 px-0 px-md-4'} %}
        {% block modal_body %}
            <div class="js-item-product modal-scrollable modal-scrollable-area" data-product-id="">
                <div class="js-product-container js-quickshop-container js-quickshop-modal js-quickshop-modal-shell" data-variants="" data-quickshop-id="">
                    <div class="row no-gutters">
                        <div class="col-md-6 mb-1 px-4 px-md-0">
                            <div class="quickshop-image-container">
                                <div class="js-quickshop-image-padding">
                                    <img srcset="" class="js-item-image js-quickshop-img quickshop-image img-absolute-centered"/>
                                </div>
                            </div>
                        </div>
                        <div class="js-item-variants col-md-6 pt-3 px-4 pb-4 mt-md-1 pt-md-2 pr-md-3">
                            <div class="row no-gutters align-items-center mt-md-0 mr-md-1 mb-2">
                                <div class="col">
                                    <div class="js-item-name h4 h2-md text-center text-md-left" data-store="product-item-name-{{ product.id }}"></div>
                                </div>
                                <div class="col-auto d-none d-md-block">
                                    <a class="js-modal-close modal-close pr-0">
                                        <svg class="icon-inline svg-icon-text"><use xlink:href="#times"/></svg>
                                    </a>
                                </div>
                            </div>
                            <div class="mb-4 mr-md-1 text-center text-md-left" data-store="product-item-price-{{ product.id }}">
                                <span class="js-price-display"></span>
                                <span class="js-compare-price-display price-compare"></span>
                                {{ component('payment-discount-price', {
                                        visibility_condition: settings.payment_discount_price,
                                        location: 'product',
                                        container_classes: "text-accent font-small mt-2",
                                    }) 
                                }}
                            </div>
                            {# Image is hidden but present so it can be used on cart notifiaction #}
                            
                            <div id="quickshop-form" class="mr-md-1"></div>
                        </div>
                    </div>
                </div>
            </div>
        {% endblock %}
    {% endembed %}
{% endif %}