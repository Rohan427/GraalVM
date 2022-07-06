/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.hackerrank.eshopping.product.dashboard.model;

import java.io.Serializable;

import javax.persistence.Entity;
import javax.persistence.Id;

/**
 *
 * @author Paul G. Allen <pgallen@gmail.com>
 */
@Entity (name = "Product")
public class ProductModel implements Serializable
{
    private static final long serialVersionUID = 1L;
    
    @Id
    private Long id;
    private String name;
    private String category;
    private Double retail_price;
    private Double discounted_price;
    private int discount_percent;
    private Boolean availability;

    /**
     *
     */
    public ProductModel()
    {
    }

    /**
     *
     * @param id
     * @param name
     * @param category
     * @param retail_price
     * @param discounted_price
     * @param availability
     */
    public ProductModel (Long id,
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

    /**
     *
     * @return
     */
    public Long getId()
    {
        return id;
    }

    /**
     *
     * @param id
     */
    public void setId (Long id)
    {
        this.id = id;
    }

    /**
     *
     * @return
     */
    public String getName()
    {
        return name;
    }

    /**
     *
     * @param name
     */
    public void setName (String name)
    {
        this.name = name;
    }

    /**
     *
     * @return
     */
    public String getCategory()
    {
        return category;
    }

    /**
     *
     * @param category
     */
    public void setCategory (String category)
    {
        this.category = category;
    }

    /**
     *
     * @return
     */
    public Boolean getAvailability()
    {
        return availability;
    }

    /**
     *
     * @param availability
     */
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
        this.discounted_price = discounted_price;
    }

    /**
     *
     * @return
     */
    public int getDiscount_percent()
    {
        return discount_percent;
    }

    /**
     * @param discount_percent
     */
    public void setDiscount_percent (int discount_percent)
    {
        this.discount_percent = discount_percent;
    }
}
