package com.randomlogic.perftest.product.dashboard.model;

import java.io.Serializable;

public class Product implements Serializable
{
    private static final long serialVersionUID = 1L;

    private final boolean DEBUG = true;

    private Long id;
    private String name;
    private String category;
    private Double retail_price = 0.00;
    private Double discounted_price = 0.00;
    private int discount_percent = 0;
    private Boolean availability;

    public Product()
    {
    }

    public Product (Long id,
                    String name,
                    String category,
                    Double retail_price,
                    Double discounted_price,
                    Boolean availability
                   )
    {
        this.id = id;
        this.name = name;
        this.category = category;
        this.retail_price = retail_price;
        this.discounted_price = discounted_price;
        this.availability = availability;
    }

    public Long getId()
    {
        return id;
    }

    public void setId (Long id)
    {
        this.id = id;
    }

    public String getName()
    {
        return name;
    }

    public void setName (String name)
    {
        this.name = name;
    }

    public String getCategory()
    {
        return category;
    }

    public void setCategory (String category)
    {
        this.category = category;
    }

    public Boolean getAvailability()
    {
        return availability;
    }

    public void setAvailability (Boolean availability)
    {
        this.availability = availability;
    }

    /**
     * @return the retail_Price
     */
    public Double getRetail_price()
    {
        return retail_price;
    }

    /**
     * @param retail_price the retail_Price to set
     */
    public void setRetail_price (Double retail_price)
    {
        if (discounted_price != 0.00)
        {
            setDiscountPercent();
        }
        // else do nothing

        this.retail_price = retail_price;
    }

    /**
     * @return the discounted_Price
     */
    public Double getDiscounted_price()
    {
        return discounted_price;
    }

    /**
     * @param discounted_price the discounted_Price to set
     */
    public void setDiscounted_price (Double discounted_price)
    {
        if (retail_price != 0.00)
        {
            setDiscountPercent();
        }
        // else do nothing

        this.discounted_price = discounted_price;
    }

    /**
     * DisPercent = (retail - discounted)/retail * 100
     *
     * @return the discount_percent
     */
    public int getDiscount_percent()
    {
        return discount_percent;
    }

    /**
     * DisPercent = (retail - discounted)/retail * 100
     *
     * @param discount_percent the discount_percent to set
     */
    public void setDiscount_percent (int discount_percent)
    {
        this.discount_percent = discount_percent;
    }

    /* DisPercent = (retail - discounted)/retail * 100 */
    private void setDiscountPercent()
    {
        if (retail_price > 0.00 && (retail_price > discounted_price))
        {
            this.discount_percent = (int)((retail_price - discounted_price) / retail_price * 100.00);
        }
    }
}
