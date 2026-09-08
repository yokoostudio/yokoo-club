<div class="js-accordion-container{% if store.branches|length > 1 %} js-toggle-branches{% endif %}">
    {% set show_product_shipping = settings.shipping_calculator_product_page and store.has_shipping %}
    <div class="font-small mb-1 {% if show_product_shipping %}mt-2 pt-1{% endif %}">
        {% if store.branches|length > 1 %}
            {{ 'Nuestros locales' | translate }}
        {% else %}
            {{ 'Nuestro local' | translate }}
        {% endif %}
    </div>
    {% if store.branches|length > 1 %}
        <a href="#" class="js-accordion-toggle btn-link font-small">
            <span class="js-accordion-toggle-inactive">
                {{ 'Ver opciones' | translate }}
            </span>
            <span class="js-accordion-toggle-active" style="display: none;">
                {{ 'Ocultar opciones' | translate }}
            </span>
        </a>
    {% endif %}
    <div class="js-accordion-content mt-3"{% if store.branches|length > 1 %} style="display: none;"{% endif %}>
    {% if not product_detail %}
        <div class="radio-buttons-group">
    {% else %}
        <div class="list">
    {% endif %}
            <ul class="radio-button-container list-unstyled">

                {% for branch in store.branches %}
                    <li class="card {% if product_detail %}list-item list-item-shipping radio-button{% else %}radio-button-item{% endif %} p-3 mb-2 {% if loop.last %}mb-0{% endif %}" data-store="branch-item-{{ branch.code }}">

                        {# If cart use radiobutton #}

                        {% if not product_detail %}
                            <label class="js-shipping-radio js-branch-radio radio-button" data-loop="branch-radio-{{loop.index}}">
                        
                                <input 
                                class="js-branch-method {% if cart.shipping_data.code == branch.code %} js-selected-shipping-method {% endif %} shipping-method" 
                                data-price="0" 
                                {% if cart.shipping_data.code == branch.code %}checked{% endif %} type="radio" 
                                value="{{branch.code}}" 
                                data-name="{{ branch.name }} - {{ branch.extra }}"
                                data-code="{{branch.code}}" 
                                data-cost="{{ 'Gratis' | translate }}"
                                name="option" 
                                style="display:none">
                                <div class="shipping-option row-fluid radio-button-content">
                                   <div class="radio-button-icons-container">
                                        <span class="radio-button-icons">
                                            <span class="radio-button-icon unchecked"></span>
                                            <span class="radio-button-icon checked"></span>
                                        </span>
                                    </div>
                        {% endif %}
                                    <div class="{% if product_detail %}list-item-content{% else %}radio-button-label ml-1{% endif %}">
                                        <div class="row">
                                            <div class="col font-small {% if not product_detail %}pr-3{% endif %}">
                                                <div>{{ branch.name }} - {{ branch.extra }}</div>
                                            </div>
                                            <div class="col-auto text-right">
                                                <p class="text-accent mb-0 d-inline-block">{{ 'Gratis' | translate }}</p>
                                            </div>
                                        </div>
                                    </div>
                        {% if not product_detail %}
                                </div>
                            </label>
                        {% endif %}
                    </li>
                {% endfor %}
            </ul>
        </div>
    </div>
</div>