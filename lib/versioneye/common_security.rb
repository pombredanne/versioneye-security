class CommonSecurity

  def self.mark_versions sv, product, versions
    return nil if sv.nil?
    return nil if product.nil?
    return nil if versions.to_a.empty?

    versions.each do |version|
      next if version.to_s.match(/\Adev\-/)
      next if sv.affected_versions.include?(version.to_s)

      sv.affected_versions.push(version.to_s)

      product.reload
      v_db = product.version_by_number version.to_s
      if !v_db.sv_ids.include?(sv._id.to_s)
        v_db.sv_ids << sv._id.to_s
        v_db.save
      end
    end
  end

end
